// ============================================================================
// SPRINT 4 - CONSULTAS DE DEMONSTRACAO NO MONGODB
//   mongosh "mongodb://localhost:27017/vetly" --file 03_consultas_demo.js
// Cada consulta tem o equivalente relacional indicado ao lado, para o video.
// ============================================================================

print('\n1) Ficha de um animal (1 leitura; no Oracle: 4 JOINs)');
printjson(db.animais.findOne({ nome: 'Thor' }, { nome: 1, especie: 1, 'tutor.nome': 1, consultas: 1 }));

print('\n2) Animais de um tutor (indice tutor.idTutor)');
printjson(db.animais.find({ 'tutor.idTutor': 'DEMO4-T1' }, { nome: 1, especie: 1 }).toArray());

print('\n3) Faturamento por veterinario e status (espelha PKG_VETLY_RELATORIO.prc_consultas_vet_status)');
printjson(db.animais.aggregate([
  { $unwind: '$consultas' },
  { $group: {
      _id: { vet: '$consultas.veterinario.nome', status: '$consultas.status' },
      qtd: { $sum: 1 },
      total: { $sum: '$consultas.valor' } } },
  { $sort: { '_id.vet': 1, '_id.status': 1 } }
]).toArray());

print('\n4) Total geral das consultas (confere com o TOTAL GERAL do relatorio Oracle)');
printjson(db.animais.aggregate([
  { $unwind: '$consultas' },
  { $group: { _id: null, qtd: { $sum: 1 }, total: { $sum: '$consultas.valor' } } }
]).toArray());

print('\n5) Consultas realizadas em outubro/2026');
printjson(db.animais.aggregate([
  { $unwind: '$consultas' },
  { $match: { 'consultas.status': 'REALIZADA',
              'consultas.dataHora': { $gte: new Date('2026-10-01T00:00:00Z'), $lt: new Date('2026-11-01T00:00:00Z') } } },
  { $project: { _id: 0, animal: '$nome', data: '$consultas.dataHora', vet: '$consultas.veterinario.nome' } }
]).toArray());
