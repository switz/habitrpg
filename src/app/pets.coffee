_ = require 'underscore'
{ randomVal } = require './helpers'
{ pets, food } = require('./items').items

###
  app exports
###
module.exports.app = (appExports, model) ->
  user = model.at '_user'

  user.on 'set', 'flags.dropsEnabled', (captures, args) ->
    return unless captures == true

    egg = randomVal pets

    dontPersist =  model._dontPersist

    model._dontPersist = false
    user.push 'items.eggs', egg
    model._dontPersist = dontPersist

    $('#drops-enabled-modal').modal 'show'

  appExports.chooseEgg = (e, el) ->
    model.ref '_feedEgg', e.at()

  appExports.feedEgg = (e, el) ->
    foodName = $(el).children('select').val()
    myFood = user.get 'items.food'
    egg = model.get '_feedEgg'
    eggs = user.get 'items.eggs'

    foodIdx = myFood.indexOf foodName
    eggIdx = eggs.indexOf egg

    return alert "You don't own that food :\\" if foodIdx is -1
    return alert "You don't own that egg :\\" if eggIdx is -1

    user.push 'items.pets', egg.name + '-' + foodName
    user.remove 'items.food', foodIdx, 1
    user.remove 'items.eggs', eggIdx, 1

  appExports.choosePet = (e, el) ->
    petArray = $(el).attr('data-pet').split '-'
    name = petArray[0]
    modifier = petArray[1]
    petStr = "#{name}-#{modifier}"
    pet = _.findWhere pets, name: name
    pet.modifier = modifier
    pet.str = petStr
    ownsThisPet = user.get('items.pets').indexOf petStr
    if ownsThisPet != -1
      # If user's pet is already active, deselect it
      pet = {} if user.get('items.currentPet.str') is petStr
      user.set 'items.currentPet', pet
    else
      tokens = user.get('balance')*4
      if tokens > pet.value
        r = confirm("Buy this pet with #{pet.value} of your #{tokens} tokens?");
        if r
          user.push 'items.pets', name
          user.set 'items.currentPet', pet
          user.set 'balance', (tokens - pet.value)/4
      else
        $('#more-tokens-modal').modal 'show'

  appExports.buyFood = (e, el) ->
    name = $(el).attr 'data-food'
    newFood = _.findWhere food, name: name
    tokens = user.get('balance') * 4
    if tokens > newFood.value
      if confirm "Buy this food with #{newFood.value} of your #{tokens} tokens?"
        user.push 'items.food', newFood.name
        user.set 'balance', (tokens - newFood.value) / 4
    else
      $('#more-tokens-modal').modal 'show'
