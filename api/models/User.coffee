module.exports =
  tableName: 'user'
  schema: true
  autoPK: false
  attributes:
    email:
      type: 'email'
      primaryKey: true
      unique: true
      required: true
    name:
      type: 'string'
      required: true
      unique: true
