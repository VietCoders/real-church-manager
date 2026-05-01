/// <reference path="../pb_data/types.d.ts" />
// Cert print logs — track ai in chứng chỉ Bí Tích nào, khi nào.

migrate((db) => {
  const dao = new Dao(db);
  try { dao.findCollectionByNameOrId('cert_print_logs'); return; } catch (_) {}

  dao.saveCollection(new Collection({
    id: 'rcm_certprintl',
    name: 'cert_print_logs',
    type: 'base',
    schema: [
      {
        name: 'sacrament_type',
        type: 'select',
        required: true,
        options: { maxSelect: 1, values: ['baptism', 'confirmation', 'marriage', 'anointing', 'funeral'] },
      },
      { name: 'sacrament_record_id', type: 'text', required: true, options: { max: 100 } },
      {
        name: 'member_id',
        type: 'relation',
        options: { collectionId: 'rcm_members0000', cascadeDelete: false, maxSelect: 1 },
      },
      {
        name: 'user_id',
        type: 'relation',
        options: { collectionId: '_pb_users_auth_', cascadeDelete: false, maxSelect: 1 },
      },
      { name: 'note', type: 'text', options: { max: 500 } },
    ],
    indexes: [
      'CREATE INDEX idx_cert_print_member ON cert_print_logs (member_id)',
      'CREATE INDEX idx_cert_print_created ON cert_print_logs (created)',
    ],
    listRule: '@request.auth.id != ""',
    viewRule: '@request.auth.id != ""',
    createRule: '@request.auth.id != ""',
    updateRule: null,
    deleteRule: '@request.auth.role = "priest_pastor"',
  }));
}, (db) => {
  const dao = new Dao(db);
  try { dao.deleteCollection(dao.findCollectionByNameOrId('cert_print_logs')); } catch (_) {}
});
