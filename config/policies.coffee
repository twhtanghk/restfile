module.exports = 
  policies:
    FileController:
      '*': false
      find: ['isAuth']
      findOne: ['isAuth', 'file/canIndex', 'file/setVersion']
      version: ['isAuth', 'file/canIndex']
      content: ['isAuth', 'file/canRead', 'file/setVersion']
      dir: ['isAuth', 'file/canIndex']
      create: ['isAuth', 'setOwner', 'file/canCreate']
      update: ['isAuth', 'file/canUpdate']
      destroy: ['isAuth', 'file/canDelete']
