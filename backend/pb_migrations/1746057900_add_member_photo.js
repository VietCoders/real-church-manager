/// <reference path="../pb_data/types.d.ts" />
// Thêm field photo (file type) vào members collection.

migrate((db) => {
  const dao = new Dao(db);
  const col = dao.findCollectionByNameOrId('members');

  // Skip nếu đã có
  if (col.schema.getFieldByName('photo')) {
    console.log('add_member_photo: bỏ qua, photo đã có');
    return;
  }

  col.schema.addField(new SchemaField({
    name: 'photo',
    type: 'file',
    required: false,
    options: {
      maxSelect: 1,
      maxSize: 5242880, // 5 MB
      mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
      thumbs: ['100x100', '300x300'],
    },
  }));

  dao.saveCollection(col);
  console.log('add_member_photo: thêm field photo vào members');
}, (db) => {
  const dao = new Dao(db);
  const col = dao.findCollectionByNameOrId('members');
  const f = col.schema.getFieldByName('photo');
  if (f) {
    col.schema.removeField(f.id);
    dao.saveCollection(col);
  }
});
