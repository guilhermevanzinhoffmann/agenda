class ContatoModel {
  List<Contato>? results;

  ContatoModel(this.results);

  ContatoModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = <Contato>[];
      json['results'].forEach((v) {
        results!.add(Contato.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (results != null) {
      data['results'] = results!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Contato {
  String? objectId;
  String? nome;
  String? tipoTelefone;
  String? telefone;
  String? email;
  String? caminhoFoto;
  String? createdAt;
  String? updatedAt;

  Contato(this.objectId, this.nome, this.tipoTelefone, this.telefone,
      this.email, this.caminhoFoto, this.createdAt, this.updatedAt);

  Contato.fromJson(Map<String, dynamic> json) {
    objectId = json['objectId'];
    nome = json['nome'];
    tipoTelefone = json['tipoTelefone'];
    telefone = json['telefone'];
    email = json['email'];
    caminhoFoto = json['caminhoFoto'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['objectId'] = objectId;
    data['nome'] = nome;
    data['tipoTelefone'] = tipoTelefone;
    data['telefone'] = telefone;
    data['email'] = email;
    data['caminhoFoto'] = caminhoFoto;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    return data;
  }

  Map<String, dynamic> toJsonCreate() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['nome'] = nome;
    data['tipoTelefone'] = tipoTelefone;
    data['telefone'] = telefone;
    data['email'] = email;
    data['caminhoFoto'] = caminhoFoto;
    return data;
  }
}
