debug = require('debug')('Uploader')
fs = require('fs')
request = require('request')
uuid = require('node-uuid')
Promise = require('bluebird')
MassUpload = require('js-mass-upload')

module.exports = class Uploader
  constructor: (@options) ->
    throw 'Must pass options.server, a server URL' if !@options.server
    throw 'Must pass options.apiToken, an API Token' if !@options.apiToken
    throw 'Must pass options.documentSetId, a DocumentSet ID' if !@options.documentSetId

    @massUpload = new MassUpload
      doListFiles: @_doListFiles.bind(@)
      doUploadFile: @_doUploadFile.bind(@)
      doDeleteFile: @_doDeleteFile.bind(@)
      onUploadConflictingFile: @_onUploadConflictingFile.bind(@)

    @req = request.defaults
      auth:
        user: @options.apiToken
        pass: 'x-auth-token'
    @reqPromise = Promise.promisify(@req)

  _doUploadFile: (file, progress, success, error) ->
    guid = uuid.v4(random: new Buffer(file.name + '        ', 'utf-8').slice(0, 16).toJSON())
    debug("Uploading #{file.name}...")

    stream = fs.createReadStream(file.name)
    stream.pipe(@req.post("#{@options.server}/api/v1/files/#{guid}", headers: { 'Content-Length': file.size }))
      .on('error', (e) -> console.warn(e); error(e))
      .on 'response', (response) ->
        if 200 <= response.statusCode < 300
          success()
        else
          debug("Error")
          response.on('data', (buf) -> console.warn(buf.toString()))
          error()

  _doListFiles: -> throw new Error("Not implemented")
  _doDeleteFile: -> throw new Error("Not implemented")
  _onUploadConflictingFile: -> throw new Error("Not implemented")

  upload: (filenames) ->
    statPromise = Promise.promisify(fs.stat)

    filenameToFile = (filename) ->
      statPromise(filename)
        .then (stats) ->
          name: filename
          size: stats.size
          lastModifiedDate: stats.mtime

    Promise.map(filenames, filenameToFile)
      .then (files) =>
        @massUpload.addFiles(files)

        new Promise (resolve, reject) =>
          listener = (model, status) =>
            if status == 'waiting'
              resolve()
              @massUpload.off()
            else if status == 'waiting-error'
              reject(model.get('uploadErrors')[0].errorDetail)
              @massUpload.off()
          @massUpload.on('change:status', listener)
