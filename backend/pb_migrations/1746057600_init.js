/// <reference path="../pb_data/types.d.ts" />
// Real Church Manager — Init migration v1.0.0
// PB v0.22.21 JSVM. `users` đã có sẵn trong PB → extend bằng custom fields.
// 15 collections mới: parish_settings, districts, members, families, family_members,
// 5 sacrament_*, groups, group_members, mass_intentions, donations, liturgical_events.

migrate((db) => {
  const dao = new Dao(db);

  // Extend default users auth collection với role/member_id/name/avatar.
  const usersCol = dao.findCollectionByNameOrId('users');
  usersCol.schema.addField(new SchemaField({"name":"name","type":"text","required":true,"options":{"max":200}}));
  usersCol.schema.addField(new SchemaField({"name":"role","type":"select","required":true,"options":{"maxSelect":1,"values":["priest_pastor","priest_assistant","secretary","council_member","guest"]}}));
  usersCol.schema.addField(new SchemaField({"name":"member_id","type":"relation","required":false,"options":{"collectionId":"rcm_members0000","cascadeDelete":false,"maxSelect":1}}));
  usersCol.schema.addField(new SchemaField({"name":"avatar","type":"file","required":false,"options":{"maxSize":5242880,"mimeTypes":["image/jpeg","image/png","image/webp"],"maxSelect":1}}));
  usersCol.listRule = "@request.auth.role = \"priest_pastor\"";
  usersCol.viewRule = "@request.auth.id != \"\"";
  usersCol.createRule = "@request.auth.role = \"priest_pastor\"";
  usersCol.updateRule = "@request.auth.id = id || @request.auth.role = \"priest_pastor\"";
  usersCol.deleteRule = "@request.auth.role = \"priest_pastor\"";
  dao.saveCollection(usersCol);

  // parish_settings
  dao.saveCollection(new Collection({
    "name": "parish_settings",
    "type": "base",
    "schema": [
      {
        "name": "name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "address",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "diocese",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "pastor_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "phone",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "email",
        "type": "email"
      },
      {
        "name": "logo",
        "type": "file",
        "options": {
          "maxSize": 2097152,
          "mimeTypes": [
            "image/png",
            "image/jpeg"
          ],
          "maxSelect": 1
        }
      },
      {
        "name": "seal",
        "type": "file",
        "options": {
          "maxSize": 2097152,
          "mimeTypes": [
            "image/png",
            "image/jpeg"
          ],
          "maxSelect": 1
        }
      },
      {
        "name": "founding_year",
        "type": "number",
        "options": {
          "min": 1500,
          "max": 2200,
          "noDecimal": true
        }
      },
      {
        "name": "patron_saint",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "feast_day",
        "type": "date"
      },
      {
        "name": "notes",
        "type": "editor"
      }
    ],
    "indexes": [],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role = \"priest_pastor\"",
    "updateRule": "@request.auth.role ?~ \"priest_\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_parishsetti"
  }));

  // districts
  dao.saveCollection(new Collection({
    "name": "districts",
    "type": "base",
    "schema": [
      {
        "name": "name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "code",
        "type": "text",
        "options": {
          "max": 50,
          "pattern": "^[A-Z0-9-]+$"
        }
      },
      {
        "name": "head_member_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "address_zone",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "deleted_at",
        "type": "date"
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_districts_code ON districts (code) WHERE code != ''"
    ],
    "listRule": "@request.auth.id != \"\" && deleted_at = null",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_districts00"
  }));

  // members
  dao.saveCollection(new Collection({
    "name": "members",
    "type": "base",
    "schema": [
      {
        "name": "saint_name",
        "type": "text",
        "options": {
          "max": 100
        }
      },
      {
        "name": "full_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "gender",
        "type": "select",
        "options": {
          "maxSelect": 1,
          "values": [
            "male",
            "female",
            "other"
          ]
        }
      },
      {
        "name": "birth_date",
        "type": "date"
      },
      {
        "name": "birth_place",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "death_date",
        "type": "date"
      },
      {
        "name": "district_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_districts00",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "family_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_families000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "father_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "mother_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "father_name_text",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "mother_name_text",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "spouse_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "phone",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "email",
        "type": "email"
      },
      {
        "name": "address",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "photo",
        "type": "file",
        "options": {
          "maxSize": 5242880,
          "mimeTypes": [
            "image/jpeg",
            "image/png",
            "image/webp"
          ],
          "maxSelect": 1
        }
      },
      {
        "name": "id_number",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "baptism_date",
        "type": "date"
      },
      {
        "name": "baptism_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_sacramentba",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "confirmation_date",
        "type": "date"
      },
      {
        "name": "confirmation_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_sacramentco",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "marriage_date",
        "type": "date"
      },
      {
        "name": "marriage_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_sacramentma",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "funeral_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_sacramentfu",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "tags",
        "type": "json"
      },
      {
        "name": "status",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "active",
            "moved_out",
            "deceased",
            "excommunicated"
          ]
        }
      },
      {
        "name": "deleted_at",
        "type": "date"
      }
    ],
    "indexes": [
      "CREATE INDEX idx_members_full_name ON members (full_name)",
      "CREATE INDEX idx_members_district ON members (district_id)",
      "CREATE INDEX idx_members_family ON members (family_id)",
      "CREATE INDEX idx_members_status ON members (status)"
    ],
    "listRule": "@request.auth.id != \"\" && deleted_at = null",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_members0000"
  }));

  // families
  dao.saveCollection(new Collection({
    "name": "families",
    "type": "base",
    "schema": [
      {
        "name": "family_name",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "head_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "district_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_districts00",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "address",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "phone",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "deleted_at",
        "type": "date"
      }
    ],
    "indexes": [
      "CREATE INDEX idx_families_district ON families (district_id)",
      "CREATE INDEX idx_families_head ON families (head_id)"
    ],
    "listRule": "@request.auth.id != \"\" && deleted_at = null",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_families000"
  }));

  // family_members
  dao.saveCollection(new Collection({
    "name": "family_members",
    "type": "base",
    "schema": [
      {
        "name": "family_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_families000",
          "cascadeDelete": true,
          "maxSelect": 1
        }
      },
      {
        "name": "member_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": true,
          "maxSelect": 1
        }
      },
      {
        "name": "role",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "head",
            "spouse",
            "child",
            "parent",
            "sibling",
            "other"
          ]
        }
      },
      {
        "name": "joined_date",
        "type": "date"
      },
      {
        "name": "left_date",
        "type": "date"
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_family_member_pair ON family_members (family_id, member_id)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "id": "rcm_familymembe"
  }));

  // sacrament_baptism
  dao.saveCollection(new Collection({
    "name": "sacrament_baptism",
    "type": "base",
    "schema": [
      {
        "name": "book_number",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "member_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "baptism_date",
        "type": "date",
        "required": true
      },
      {
        "name": "baptism_place",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "priest_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "godfather_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "godmother_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "godfather_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "godmother_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "father_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "mother_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "attachment",
        "type": "file",
        "options": {
          "maxSize": 10485760,
          "maxSelect": 5
        }
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_baptism_book_number ON sacrament_baptism (book_number) WHERE book_number != ''",
      "CREATE INDEX idx_baptism_member ON sacrament_baptism (member_id)",
      "CREATE INDEX idx_baptism_date ON sacrament_baptism (baptism_date)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_sacramentba"
  }));

  // sacrament_confirmation
  dao.saveCollection(new Collection({
    "name": "sacrament_confirmation",
    "type": "base",
    "schema": [
      {
        "name": "book_number",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "member_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "confirmation_date",
        "type": "date",
        "required": true
      },
      {
        "name": "confirmation_place",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "bishop_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "confirmation_saint_name",
        "type": "text",
        "options": {
          "max": 100
        }
      },
      {
        "name": "sponsor_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "sponsor_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "attachment",
        "type": "file",
        "options": {
          "maxSize": 10485760,
          "maxSelect": 5
        }
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_confirmation_book_number ON sacrament_confirmation (book_number) WHERE book_number != ''",
      "CREATE INDEX idx_confirmation_member ON sacrament_confirmation (member_id)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_sacramentco"
  }));

  // sacrament_marriage
  dao.saveCollection(new Collection({
    "name": "sacrament_marriage",
    "type": "base",
    "schema": [
      {
        "name": "book_number",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "groom_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "bride_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "marriage_date",
        "type": "date",
        "required": true
      },
      {
        "name": "marriage_place",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "priest_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "groom_father_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "groom_mother_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "bride_father_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "bride_mother_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "witness_1_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "witness_2_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "witness_1_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "witness_2_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "dispensation",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "attachment",
        "type": "file",
        "options": {
          "maxSize": 10485760,
          "maxSelect": 5
        }
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_marriage_book_number ON sacrament_marriage (book_number) WHERE book_number != ''",
      "CREATE INDEX idx_marriage_groom ON sacrament_marriage (groom_id)",
      "CREATE INDEX idx_marriage_bride ON sacrament_marriage (bride_id)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_sacramentma"
  }));

  // sacrament_anointing
  dao.saveCollection(new Collection({
    "name": "sacrament_anointing",
    "type": "base",
    "schema": [
      {
        "name": "member_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "anointing_date",
        "type": "date",
        "required": true
      },
      {
        "name": "anointing_place",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "priest_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "condition",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "notes",
        "type": "editor"
      }
    ],
    "indexes": [
      "CREATE INDEX idx_anointing_member ON sacrament_anointing (member_id)",
      "CREATE INDEX idx_anointing_date ON sacrament_anointing (anointing_date)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\"",
    "updateRule": "@request.auth.role ?~ \"priest_\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_sacramentan"
  }));

  // sacrament_funeral
  dao.saveCollection(new Collection({
    "name": "sacrament_funeral",
    "type": "base",
    "schema": [
      {
        "name": "book_number",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "member_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "death_date",
        "type": "date",
        "required": true
      },
      {
        "name": "death_cause",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "funeral_date",
        "type": "date",
        "required": true
      },
      {
        "name": "burial_place",
        "type": "text",
        "options": {
          "max": 300
        }
      },
      {
        "name": "priest_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "attachment",
        "type": "file",
        "options": {
          "maxSize": 10485760,
          "maxSelect": 5
        }
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_funeral_book_number ON sacrament_funeral (book_number) WHERE book_number != ''",
      "CREATE INDEX idx_funeral_member ON sacrament_funeral (member_id)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_sacramentfu"
  }));

  // groups
  dao.saveCollection(new Collection({
    "name": "groups",
    "type": "base",
    "schema": [
      {
        "name": "name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "code",
        "type": "text",
        "options": {
          "max": 50,
          "pattern": "^[A-Z0-9-]+$"
        }
      },
      {
        "name": "type",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "confraternity",
            "youth",
            "choir",
            "pastoral",
            "other"
          ]
        }
      },
      {
        "name": "head_member_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "vice_head_member_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "founding_date",
        "type": "date"
      },
      {
        "name": "meeting_schedule",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "notes",
        "type": "editor"
      },
      {
        "name": "deleted_at",
        "type": "date"
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_groups_code ON groups (code) WHERE code != ''",
      "CREATE INDEX idx_groups_type ON groups (type)"
    ],
    "listRule": "@request.auth.id != \"\" && deleted_at = null",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\" || @request.auth.role = \"council_member\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_groups00000"
  }));

  // group_members
  dao.saveCollection(new Collection({
    "name": "group_members",
    "type": "base",
    "schema": [
      {
        "name": "group_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_groups00000",
          "cascadeDelete": true,
          "maxSelect": 1
        }
      },
      {
        "name": "member_id",
        "type": "relation",
        "required": true,
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": true,
          "maxSelect": 1
        }
      },
      {
        "name": "role",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "head",
            "vice_head",
            "secretary",
            "treasurer",
            "member"
          ]
        }
      },
      {
        "name": "joined_date",
        "type": "date"
      },
      {
        "name": "left_date",
        "type": "date"
      },
      {
        "name": "notes",
        "type": "text",
        "options": {
          "max": 500
        }
      }
    ],
    "indexes": [
      "CREATE UNIQUE INDEX idx_group_member_pair ON group_members (group_id, member_id) WHERE left_date = null"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\" || @request.auth.role = \"council_member\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\" || @request.auth.role = \"council_member\"",
    "deleteRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "id": "rcm_groupmember"
  }));

  // mass_intentions
  dao.saveCollection(new Collection({
    "name": "mass_intentions",
    "type": "base",
    "schema": [
      {
        "name": "intention_text",
        "type": "text",
        "required": true,
        "options": {
          "max": 1000
        }
      },
      {
        "name": "requester_name",
        "type": "text",
        "required": true,
        "options": {
          "max": 200
        }
      },
      {
        "name": "requester_member_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "mass_date",
        "type": "date"
      },
      {
        "name": "priest_id",
        "type": "relation",
        "options": {
          "collectionId": "_pb_users_auth_",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "donation_amount",
        "type": "number",
        "options": {
          "min": 0,
          "noDecimal": false
        }
      },
      {
        "name": "status",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "pending",
            "scheduled",
            "done",
            "cancelled"
          ]
        }
      },
      {
        "name": "notes",
        "type": "editor"
      }
    ],
    "indexes": [
      "CREATE INDEX idx_mass_intention_date ON mass_intentions (mass_date)",
      "CREATE INDEX idx_mass_intention_status ON mass_intentions (status)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "@request.auth.id != \"\"",
    "createRule": "@request.auth.id != \"\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role ?~ \"priest_\"",
    "id": "rcm_massintenti"
  }));

  // donations
  dao.saveCollection(new Collection({
    "name": "donations",
    "type": "base",
    "schema": [
      {
        "name": "date",
        "type": "date",
        "required": true
      },
      {
        "name": "type",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "sunday_offering",
            "feast_offering",
            "building_fund",
            "mass_intention",
            "other_in",
            "expense"
          ]
        }
      },
      {
        "name": "amount",
        "type": "number",
        "required": true
      },
      {
        "name": "currency",
        "type": "text",
        "options": {
          "max": 10,
          "pattern": "^[A-Z]{3}$"
        }
      },
      {
        "name": "donor_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "donor_member_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_members0000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "family_id",
        "type": "relation",
        "options": {
          "collectionId": "rcm_families000",
          "cascadeDelete": false,
          "maxSelect": 1
        }
      },
      {
        "name": "description",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "receipt_no",
        "type": "text",
        "options": {
          "max": 50
        }
      },
      {
        "name": "notes",
        "type": "editor"
      }
    ],
    "indexes": [
      "CREATE INDEX idx_donations_date ON donations (date)",
      "CREATE INDEX idx_donations_type ON donations (type)",
      "CREATE UNIQUE INDEX idx_donations_receipt ON donations (receipt_no) WHERE receipt_no != ''"
    ],
    "listRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\" || @request.auth.role = \"council_member\"",
    "viewRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\" || @request.auth.role = \"council_member\"",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role = \"priest_pastor\"",
    "id": "rcm_donations00"
  }));

  // liturgical_events
  dao.saveCollection(new Collection({
    "name": "liturgical_events",
    "type": "base",
    "schema": [
      {
        "name": "title",
        "type": "text",
        "required": true,
        "options": {
          "max": 300
        }
      },
      {
        "name": "event_date",
        "type": "date",
        "required": true
      },
      {
        "name": "end_date",
        "type": "date"
      },
      {
        "name": "event_type",
        "type": "select",
        "required": true,
        "options": {
          "maxSelect": 1,
          "values": [
            "mass_regular",
            "mass_solemn",
            "mass_feast",
            "confession",
            "adoration",
            "meeting",
            "other"
          ]
        }
      },
      {
        "name": "liturgical_color",
        "type": "select",
        "options": {
          "maxSelect": 1,
          "values": [
            "white",
            "red",
            "green",
            "purple",
            "rose",
            "black"
          ]
        }
      },
      {
        "name": "priest_name",
        "type": "text",
        "options": {
          "max": 200
        }
      },
      {
        "name": "is_recurring",
        "type": "bool"
      },
      {
        "name": "recurrence_rule",
        "type": "text",
        "options": {
          "max": 500
        }
      },
      {
        "name": "notes",
        "type": "editor"
      }
    ],
    "indexes": [
      "CREATE INDEX idx_liturgical_date ON liturgical_events (event_date)",
      "CREATE INDEX idx_liturgical_type ON liturgical_events (event_type)"
    ],
    "listRule": "@request.auth.id != \"\"",
    "viewRule": "",
    "createRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "updateRule": "@request.auth.role ?~ \"priest_\" || @request.auth.role = \"secretary\"",
    "deleteRule": "@request.auth.role ?~ \"priest_\"",
    "id": "rcm_liturgicale"
  }));
}, (db) => {
  const dao = new Dao(db);
  try { dao.deleteCollection(dao.findCollectionByNameOrId("liturgical_events")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("donations")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("mass_intentions")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("group_members")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("groups")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("sacrament_funeral")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("sacrament_anointing")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("sacrament_marriage")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("sacrament_confirmation")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("sacrament_baptism")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("family_members")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("families")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("members")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("districts")); } catch (e) {}
  try { dao.deleteCollection(dao.findCollectionByNameOrId("parish_settings")); } catch (e) {}
  // Note: KHÔNG xoá default users collection.
});
