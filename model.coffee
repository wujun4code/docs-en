path = require 'path'
fs = require 'fs'

_ = require 'underscore'

exports.getTmpls = () ->
  stats = fs.readdirSync(path.join(__dirname, 'views'))
  stats = _.filter stats, (stat) ->
    return stat.search(/\.tmpl$/) > 0
  return _.map stats, (stat) ->
    return stat.replace '.tmpl', ''

exports.getImpls = (tmpl) ->
  stats = fs.readdirSync(path.join(__dirname, 'views'))
  re = new RegExp("^#{tmpl}-(.*)\.md$")
  return _.compact _.map stats, (stat) ->
    result = stat.match re
    return result[1] if result?

exports.getBlock = (tmpl, impl, block) ->
  blocks = exports.getBlocks tmpl, impl
  block = _.find blocks, {block}
  unless block
    block = {block: block, content: ''}
  return block

exports.getBlocks = (tmpl, impl) ->
  blockRe = /{%\s+block\s+(\w+)\s+%}\n{0,2}([\s\S]+?)\n?{%\s+endblock\s+%}/gm
  content = fs.readFileSync(
    path.join(__dirname, 'views', "#{tmpl}-#{impl}.md"), {encoding: 'utf-8'})
  blocks = []
  while (result = blockRe.exec(content)) != null
    blocks.push
      block: result[1]
      content: result[2]
  return blocks

exports.getVars = (tmpl, impl) ->
  varRe = /{%\s?set\s+(\w+)\s*=\s*["'](.*)["']\s*%}/gm
  content = fs.readFileSync(
    path.join(__dirname, 'views', "#{tmpl}-#{impl}.md"), {encoding: 'utf-8'})
  vars = []
  while (result = varRe.exec(content)) != null
    vars.push
      key: result[1]
      value: result[2]
  return vars

exports.saveBlock = (tmpl, impl, block, content) ->
  vars = exports.getVars tmpl, impl
  blocks = exports.getBlocks tmpl, impl
  isExist = false
  _.each blocks, (b) ->
    if b.block is block
      b.content = content
      isExist = true
  unless isExist
    blocks.push {block: block, content: content}
  save tmpl, impl, vars, blocks

save = (tmpl, impl, vars, blocks) ->
  content = _.reduce vars, (result, v) ->
    result += "{% set #{v.key} = \"#{v.value}\" %}\n"
  , "{% extends \"./#{tmpl}.tmpl\" %}\n\n"
  content = _.reduce blocks, (result, block) ->
    result += "\n{% block #{block.block} %}\n\n#{block.content}\n{% endblock %}\n"
  , content
  fs.writeFileSync(
    path.join(__dirname, 'views',
    "#{tmpl}-#{impl}.md"), content, {encoding: 'utf-8'})

exports.getTmplParagraphs = (tmpl) ->
  content = fs.readFileSync(
    path.join(__dirname, 'views', "#{tmpl}.tmpl"), {encoding: 'utf-8'})
  result = content.split '\n\n' # 两个连续回车认为是一个段落
  return _.filter result, (p) ->
    return p != ''

exports.saveTmplParagraph = (tmpl, index, content) ->
  finalPs = []
  for p, i in getTmplParagraphs tmpl
    if i is index
      finalPs.push content
    else
      finalPs.push p
  content = _.reduce finalPs, (result, p) ->
    result += "#{p}\n\n"
  , ''
  fs.writeFileSync(
    path.join(__dirname, 'views', "#{tmpl}.tmpl"), content, {encoding: 'utf-8'}
  )

