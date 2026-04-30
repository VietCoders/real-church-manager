const fs = require('fs');
const j = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
function hashId(name) { return ('rcm_' + name.replace(/[^a-z0-9]/gi,'').toLowerCase() + '0000000000000').substring(0,15); }
const usersCollection = j.collections.find(c => c.name === 'users');
const newCollections = j.collections.filter(c => c.name !== 'users');
const idMap = { users: '_pb_users_auth_' };
for (const c of newCollections) { c.id = hashId(c.name); idMap[c.name] = c.id; }
for (const c of [...newCollections, usersCollection]) {
  if (!c || !c.schema) continue;
  for (const f of c.schema) {
    if (f.type === 'relation' && f.options && f.options.collectionId && idMap[f.options.collectionId]) {
      f.options.collectionId = idMap[f.options.collectionId];
    }
  }
}
const usersFieldsCode = (usersCollection.schema || []).map(f => `  usersCol.schema.addField(new SchemaField(${JSON.stringify(f)}));`).join('\n');
const usersOpts = usersCollection.options || {};
const usersOptsCode = `
  // Auth options (cho phép login bằng username thay vì email)
  const usersOpts = usersCol.options;
  usersOpts.allowUsernameAuth = ${JSON.stringify(usersOpts.allowUsernameAuth ?? true)};
  usersOpts.allowEmailAuth = ${JSON.stringify(usersOpts.allowEmailAuth ?? true)};
  usersOpts.requireEmail = ${JSON.stringify(usersOpts.requireEmail ?? false)};
  usersOpts.minPasswordLength = ${JSON.stringify(usersOpts.minPasswordLength ?? 6)};
  usersCol.options = usersOpts;`;
const usersRulesCode = `
  usersCol.listRule = ${JSON.stringify(usersCollection.listRule || null)};
  usersCol.viewRule = ${JSON.stringify(usersCollection.viewRule || null)};
  usersCol.createRule = ${JSON.stringify(usersCollection.createRule || null)};
  usersCol.updateRule = ${JSON.stringify(usersCollection.updateRule || null)};
  usersCol.deleteRule = ${JSON.stringify(usersCollection.deleteRule || null)};
  dao.saveCollection(usersCol);`;
const newCollectionsCode = newCollections.map((col) => {
  const json = JSON.stringify(col, null, 2).split('\n').map((l,i) => i===0?l:'  '+l).join('\n');
  return `  // ${col.name}\n  dao.saveCollection(new Collection(${json}));`;
}).join('\n\n');
const downBody = newCollections.map(c=>c.name).reverse().map((n) => `  try { dao.deleteCollection(dao.findCollectionByNameOrId(${JSON.stringify(n)})); } catch (e) {}`).join('\n');
const out = `/// <reference path="../pb_data/types.d.ts" />
// Real Church Manager — Init migration v1.0.0
// PB v0.22.21 JSVM. Extend default users + create 15 collections mới.

migrate((db) => {
  const dao = new Dao(db);

  const usersCol = dao.findCollectionByNameOrId('users');
${usersFieldsCode}${usersOptsCode}${usersRulesCode}

${newCollectionsCode}
}, (db) => {
  const dao = new Dao(db);
${downBody}
});
`;
fs.writeFileSync(process.argv[3], out, 'utf8');
console.log('OK size=', out.length);
