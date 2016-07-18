module.exports =
  tableName: 'fs.chunks'
  schema: true
  autoPK: true
  attributes:
    files_id:
      model: 'fsfiles'
    n:
      type: 'integer'
    data:
      type: 'binary'
