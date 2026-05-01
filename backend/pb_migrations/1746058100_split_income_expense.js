/// <reference path="../pb_data/types.d.ts" />
// Tách Sổ Thu/Sổ Chi: thêm expense_category cho phiếu chi (utilities/supplies/repair/salary/other).
// Income types vẫn giữ nguyên (sunday_offering, feast_offering, building_fund, mass_intention, other_in).

migrate((db) => {
  const dao = new Dao(db);
  const col = dao.findCollectionByNameOrId('donations');

  if (!col.schema.getFieldByName('expense_category')) {
    col.schema.addField(new SchemaField({
      name: 'expense_category',
      type: 'select',
      required: false,
      options: {
        maxSelect: 1,
        values: ['utilities', 'supplies', 'repair', 'salary', 'liturgy', 'charity', 'other'],
      },
    }));
  }

  if (!col.schema.getFieldByName('payment_method')) {
    col.schema.addField(new SchemaField({
      name: 'payment_method',
      type: 'select',
      required: false,
      options: {
        maxSelect: 1,
        values: ['cash', 'bank_transfer', 'qr_code', 'other'],
      },
    }));
  }

  // Index cho filter type theo Sổ Thu / Sổ Chi nhanh
  if (col.indexes.indexOf('CREATE INDEX idx_donations_type_date ON donations (type, date)') < 0) {
    col.indexes.push('CREATE INDEX idx_donations_type_date ON donations (type, date)');
  }

  dao.saveCollection(col);
  console.log('split_income_expense: thêm expense_category + payment_method + index type/date');
}, (db) => {
  const dao = new Dao(db);
  try {
    const col = dao.findCollectionByNameOrId('donations');
    for (const name of ['expense_category', 'payment_method']) {
      const f = col.schema.getFieldByName(name);
      if (f) col.schema.removeField(f.id);
    }
    dao.saveCollection(col);
  } catch (_) {}
});
