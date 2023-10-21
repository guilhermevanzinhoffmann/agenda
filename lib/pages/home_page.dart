import 'package:agenda/models/contato_model.dart';
import 'package:agenda/pages/contato_page.dart';
import 'package:agenda/services/back4App/back4app_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var carregando = false;
  var contatoModel = ContatoModel([]);
  var service = Back4AppService();

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  carregarDados() async {
    if (mounted) {
      setState(() {
        carregando = true;
      });

      contatoModel = await service.get(null);

      setState(() {
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text("Contatos"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: carregando
          ? const Center(child: CircularProgressIndicator())
          : contatoModel.results == null || contatoModel.results!.isEmpty
              ? const Center(child: Text("Nenhum contato encontrado"))
              : ListView.builder(
                  itemCount: contatoModel.results!.length,
                  itemBuilder: (_, int index) {
                    return Dismissible(
                      direction: DismissDirection.startToEnd,
                      onDismissed: (DismissDirection dismissDirection) async {
                        if (dismissDirection == DismissDirection.startToEnd) {
                          try {
                            await service
                                .delete(contatoModel.results![index].objectId!);
                            carregarDados();
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Contato excluído com sucesso!'),
                                elevation: 8,
                                backgroundColor: Colors.green,
                              ));
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(e.toString()),
                                elevation: 8,
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        }
                      },
                      key: Key(contatoModel.results![index].objectId!),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext bc) => ContatoPage(
                                        contatoId: contatoModel
                                            .results![index].objectId!)));
                          },
                          child: Card(
                            elevation: 10,
                            shadowColor: Colors.red,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            "Estado: ${contatoModel.results![index].nome ?? ""}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                            "Cidade: ${contatoModel.results![index].email ?? ""}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500)),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: Text(
                                        contatoModel.results![index].email ??
                                            "",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    ));
  }
}
