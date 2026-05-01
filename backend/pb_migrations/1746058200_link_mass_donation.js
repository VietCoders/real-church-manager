/// <reference path="../pb_data/types.d.ts" />
// Mass intentions ↔ Donations link: thêm field linked_donation_id để idempotent
// auto-create income khi status=done.

migrate((db) => {
  const dao = new Dao(db);
  const col = dao.findCollectionByNameOrId('mass_intentions');
  if (!col.schema.getFieldByName('linked_donation_id')) {
    col.schema.addField(new SchemaField({
      name: 'linked_donation_id',
      type: 'relation',
      required: false,
      options: {
        collectionId: dao.findCollectionByNameOrId('donations').id,
        cascadeDelete: false,
        maxSelect: 1,
      },
    }));
    dao.saveCollection(col);
    console.log('link_mass_donation: thêm linked_donation_id');
  }
}, (db) => {
  const dao = new Dao(db);
  try {
    const col = dao.findCollectionByNameOrId('mass_intentions');
    const f = col.schema.getFieldByName('linked_donation_id');
    if (f) { col.schema.removeField(f.id); dao.saveCollection(col); }
  } catch (_) {}
});
