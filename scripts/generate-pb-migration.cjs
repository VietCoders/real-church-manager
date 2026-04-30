const fs = require('fs');
const path = require('path');

const j = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));

function hashId(name) {
  const safe = name.replace(/[^a-z0-9]/gi, '').toLowerCase();
  return ('rcm_' + safe + '0000000000000').substring(0, 15);
}

// Tách users (đã có sẵn trong PB) khỏi danh sách create.
const usersCollection = j.collections.find(c => c.name === 'users');
const newCollections = j.collections.filter(c => c.name !== 'users');

const idMap = { users: '_pb_users_auth_' };  // PB default users collection ID
for (const c of newCollections) {
  c.id = hashId(c.name);
  idMap[c.name] = c.id;
}
// Resolve relation collectionIds
for (const c of [...newCollections, usersCollection]) {
  if (!c || !c.schema) continue;
  for (const f of c.schema) {
    if (f.type === 'relation' && f.options && f.options.collectionId) {
      if (idMap[f.options.collectionId]) f.options.collectionId = idMap[f.options.collectionId];
    }
  }
}

// Up: extend default users + create 15 new
const usersFields = (usersCollection.schema || []).map(f => JSON.stringify(f));
const usersFieldsCode = usersFields.map(fJson => `  usersCol.schema.addField(new SchemaField(${fJson}));`).join('\n');
const usersRulesCode = `
  usersCol.listRule = ${JSON.stringify(usersCollection.listRule || null)};
  usersCol.viewRule = ${JSON.stringify(usersCollection.viewRule || null)};
  usersCol.createRule = ${JSON.stringify(usersCollection.createRule || null)};
  usersCol.updateRule = ${JSON.stringify(usersCollection.updateRule || null)};
  usersCol.deleteRule = ${JSON.stringify(usersCollection.deleteRule || null)};
  dao.saveCollection(usersCol);`;

const newCollectionsCode = newCollections.map((col) => {
  const json = JSON.stringify(col, null, 2).split('\n').map((l, i) => i === 0 ? l : '  ' + l).join('\n');
  return `  // ${col.name}\n  dao.saveCollection(new Collection(${json}));`;
}).join('\n\n');

const downNames = newCollections.map((c) => c.name).reverse();
const downBody = downNames.map((n) => `  try { dao.deleteCollection(dao.findCollectionByNameOrId(${JSON.stringify(n)})); } catch (e) {}`).join('\n');

const out = `/// <reference path="../pb_data/types.d.ts" />
// Real Church Manager — Init migration v1.0.0
// PB v0.22.21 JSVM. \`users\` đã có sẵn trong PB → extend bằng custom fields.
// 15 collections mới: parish_settings, districts, members, families, family_members,
// 5 sacrament_*, groups, group_members, mass_intentions, donations, liturgical_events.

migrate((db) => {
  const dao = new Dao(db);

  // Extend default users auth collection với role/member_id/name/avatar.
  const usersCol = dao.findCollectionByNameOrId('users');
${usersFieldsCode}${usersRulesCode}

${newCollectionsCode}
}, (db) => {
  const dao = new Dao(db);
${downBody}
  // Note: KHÔNG xoá default users collection.
});
`;
fs.writeFileSync(process.argv[3], out, 'utf8');
console.log('OK size=', out.length, 'newCollections=', newCollections.length);
