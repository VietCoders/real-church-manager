/// <reference path="../pb_data/types.d.ts" />
// Activity logs collection — track create/update/delete trên các collection nghiệp vụ.

migrate((db) => {
  const dao = new Dao(db);
  // Skip nếu đã có
  try {
    dao.findCollectionByNameOrId('activity_logs');
    console.log('activity_logs: bỏ qua, đã tồn tại');
    return;
  } catch (_) {}

  dao.saveCollection(new Collection({
    id: 'rcm_activitylog',
    name: 'activity_logs',
    type: 'base',
    schema: [
      {
        name: 'op',
        type: 'select',
        required: true,
        options: { maxSelect: 1, values: ['create', 'update', 'delete'] }
      },
      {
        name: 'collection',
        type: 'text',
        required: true,
        options: { max: 100 }
      },
      {
        name: 'record_id',
        type: 'text',
        options: { max: 100 }
      },
      {
        name: 'user_id',
        type: 'relation',
        options: {
          collectionId: '_pb_users_auth_',
          cascadeDelete: false,
          maxSelect: 1
        }
      },
      {
        name: 'summary',
        type: 'text',
        options: { max: 500 }
      },
      {
        name: 'meta',
        type: 'json',
        options: { maxSize: 16384 }
      }
    ],
    indexes: [
      'CREATE INDEX idx_activity_created ON activity_logs (created)',
      'CREATE INDEX idx_activity_collection ON activity_logs (collection)',
      'CREATE INDEX idx_activity_user ON activity_logs (user_id)'
    ],
    listRule: '@request.auth.role = "priest_pastor"',
    viewRule: '@request.auth.role = "priest_pastor"',
    createRule: '', // server-only via JSVM
    updateRule: null,
    deleteRule: '@request.auth.role = "priest_pastor"',
  }));
  console.log('activity_logs: created');
}, (db) => {
  const dao = new Dao(db);
  try { dao.deleteCollection(dao.findCollectionByNameOrId('activity_logs')); } catch (_) {}
});
