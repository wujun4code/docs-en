should = require 'should'
model = require '../model'

describe 'model', ->

  it 'getBlocks', ->
    blocks = model.getBlocks('test', 'apple')
    blocks[0].should.eql
      block: 'test_block'
      content: 'apple test'

  it 'getVars', ->
    result = model.getVars('test', 'apple')
    result.should.eql [
      key: 'foo'
      value: 'bar'
    ,
      key: 'key1'
      value: 'value1'
    ]
      

