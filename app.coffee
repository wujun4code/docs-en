fs = require 'fs'
express = require('express')
path = require('path')
cookieParser = require('cookie-parser')
bodyParser = require('body-parser')
_ = require 'underscore'

model = require './model'

app = express()
app.use express.static('server_public')

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: false)
app.use cookieParser()

app.get '/tmpls', (req, res) ->
  res.send model.getTmpls()

app.get '/tmpls/:tmpl', (req, res) ->
  tmpl = req.params.tmpl
  res.send
    paragraphs: model.getTmplParagraphs tmpl

app.get '/tmpls/:tmpl/impls', (req, res) ->
  tmpl = req.params.tmpl
  res.send model.getImpls tmpl

app.post '/tmpls/:tmpl/paragraphs/:index', (req, res) ->
  tmpl = req.params.tmpl
  index = req.params.index
  content = req.body.content
  saveTmplParagraph tmpl, parseInt(index), content
  res.send {}

app.get '/tmpls/:tmpl/impls/:impl/blocks/:block', (req, res) ->
  block = model.getBlock req.params.tmpl, req.params.impl, req.params.block
  res.send
    blockContent: block.content

app.post '/tmpls/:tmpl/impls/:impl/blocks/:block', (req, res) ->
  tmpl = req.params.tmpl
  impl = req.params.impl
  block = req.params.block
  content = req.body.content
  model.saveBlock tmpl, impl, block, content
  res.send {}

# 如果任何路由都没匹配到，则认为 404
# 生成一个异常让后面的 err handler 捕获
app.use (req, res, next) ->
  err = new Error('Not Found')
  err.status = 404
  next err
  return

# error handlers
# 如果是开发环境，则将异常堆栈输出到页面，方便开发调试
if app.get('env') == 'development'
  app.use (err, req, res, next) ->
    res.status err.status or 500
    res.send
      message: err.message
      error: err.stack || err
    return
# 如果是非开发环境，则页面只输出简单的错误信息
app.use (err, req, res, next) ->
  res.status err.status or 500
  res.send
    message: err.message
  return

module.exports = app
