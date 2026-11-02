// ============================================================================
// SPRINT 4 - ESTRUTURA E IMPORTACAO NO MONGODB
//
//   mongosh "mongodb://localhost:27017/vetly" --file 02_importar_mongo.js
//
// Variaveis de ambiente opcionais:
//   VETLY_DATASET  caminho do NDJSON (padrao: dataset/animais.ndjson)
//
// Modelo de documento: colecao `animais`, um documento por animal, com o tutor e
// as consultas EMBUTIDOS. No relacional isso eram 6 tabelas e 4 JOINs; aqui a
// tela "ficha do animal" e uma leitura de um unico documento. Motivo do embed:
// o tutor e as consultas sao sempre lidos junto do animal e a lista de consultas
// de um animal e pequena e limitada (nao cresce sem fim).
//
// Idempotente: recria a colecao a cada execucao (drop + create + import).
// ============================================================================
const fs = require('fs');

const arquivo = process.env.VETLY_DATASET || 'dataset/animais.ndjson';
const colecao = 'animais';

print(`> Lendo ${arquivo}`);
const linhas = fs.readFileSync(arquivo, 'utf8').split('\n').filter(l => l.trim().length > 0);

// O Oracle exporta datas como string ISO sem fuso ("2026-10-01T00:00:00").
// No Mongo viram Date (UTC) para permitir filtro e ordenacao por periodo.
const paraData = s => (s ? new Date(s + 'Z') : null);

const docs = linhas.map((l, i) => {
  let d;
  try {
    d = JSON.parse(l);
  } catch (e) {
    throw new Error(`Linha ${i + 1} do dataset nao e JSON valido: ${e.message}`);
  }
  d.dataNascimento = paraData(d.dataNascimento);
  d.consultas = (d.consultas || []).map(c => ({ ...c, dataHora: paraData(c.dataHora) }));
  return d;
});

// ---- Estrutura: colecao com validacao de schema -----------------------------
db.getCollection(colecao).drop();
db.createCollection(colecao, {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['_id', 'nome', 'especie', 'tutor', 'consultas'],
      properties: {
        _id:     { bsonType: 'string' },
        nome:    { bsonType: 'string', minLength: 1 },
        especie: { bsonType: 'string' },
        sexo:    { enum: ['F', 'M'] },
        pesoKg:  { bsonType: ['double', 'int', 'null'] },
        dataNascimento: { bsonType: ['date', 'null'] },
        tutor: {
          bsonType: 'object',
          required: ['idTutor', 'nome'],
          properties: { idTutor: { bsonType: 'string' }, nome: { bsonType: 'string' } }
        },
        consultas: {
          bsonType: 'array',
          items: {
            bsonType: 'object',
            required: ['idConsulta', 'dataHora', 'status', 'valor'],
            properties: {
              status: { enum: ['AGENDADA', 'CANCELADA', 'REALIZADA', 'NAO_COMPARECEU'] },
              valor:  { bsonType: ['double', 'int', 'decimal'] },
              dataHora: { bsonType: 'date' }
            }
          }
        }
      }
    }
  }
});

// ---- Indices alinhados as consultas do painel -------------------------------
db[colecao].createIndex({ 'tutor.idTutor': 1 });                    // animais de um tutor
db[colecao].createIndex({ especie: 1, nome: 1 });                    // listagem por especie
db[colecao].createIndex({ 'consultas.veterinario.idVeterinario': 1, 'consultas.status': 1 });
db[colecao].createIndex({ 'consultas.dataHora': -1 });               // agenda por periodo

// ---- Importacao -------------------------------------------------------------
const r = db[colecao].insertMany(docs);
print(`> ${Object.keys(r.insertedIds).length} documentos importados em ${db.getName()}.${colecao}`);
printjson(db[colecao].aggregate([{ $group: { _id: '$especie', animais: { $sum: 1 } } }, { $sort: { _id: 1 } }]).toArray());
