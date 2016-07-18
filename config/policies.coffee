module.exports = 
  policies:
    UserController:
      '*': false
      find: true
      findOne: ['user/me']
    FileController:
      '*': false
      findOne: ['file/idpath']
      version: ['file/idpath']
      content: ['file/idpath', 'file/setVersion']
      create: ['setCreatedBy']
      update: ['file/idpath', 'setUpdatedBy']
      destroy: ['file/idpath', 'file/canDelete']
      mkdir: ['setCreatedBy']
    DirController:
      '*': false
      create: ['setCreatedBy']
      findOne: ['file/idpath']
      destroy: ['file/canDelete']
    PermissionController:
      '*': false
      find: ['filterCreatedBy']
      create: ['setCreatedBy']
      destroy: true
