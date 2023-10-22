import 'dart:io';

import 'package:agenda/models/contato_model.dart';
import 'package:agenda/pages/home_page.dart';
import 'package:agenda/services/back4App/back4app_service.dart';
import 'package:agenda/shared/app_images.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class ContatoPage extends StatefulWidget {
  final String? contatoId;

  const ContatoPage({super.key, required this.contatoId});

  @override
  State<ContatoPage> createState() => _ContatoPageState();
}

class _ContatoPageState extends State<ContatoPage> {
  var carregando = false;
  Back4AppService service = Back4AppService();
  Contato? contato;
  XFile? photo;
  Image? savedPhoto;
  TextEditingController nomeController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController telefoneController = TextEditingController(text: "");
  String tipoContato = "Pessoal";
  List<DropdownMenuItem> tiposContato = [
    const DropdownMenuItem(value: "Pessoal", child: Text("Pessoal")),
    const DropdownMenuItem(value: "Profissional", child: Text("Profissional"))
  ];

  bool createOrUpdateContato() {
    var nome = nomeController.text;
    if (nome.isEmpty) {
      return false;
    }

    var telefone = telefoneController.text;

    var email = emailController.text;

    var caminhoFoto = photo?.path ?? "";

    if (contato == null) {
      contato = Contato(nome, tipoContato, telefone, email, caminhoFoto);
    } else {
      contato!.caminhoFoto = caminhoFoto;
      contato!.email = email;
      contato!.nome = nome;
      contato!.telefone = telefone;
      contato!.tipoTelefone = tipoContato;
    }
    return true;
  }

  Future<void> getLostData() async {
    final ImagePicker picker = ImagePicker();
    final LostDataResponse response = await picker.retrieveLostData();
    if (response.isEmpty) {
      return;
    }
    final List<XFile>? files = response.files;
    if (files != null) {
      savedPhoto = Image.file(
        File(files[0].path),
        height: 200,
        width: 200,
      );

      photo = files[0];
    }
  }

  cropImage(XFile imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Ajustar Imagem',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Ajustar Imagem',
        )
      ],
    );
    if (croppedFile != null) {
      await GallerySaver.saveImage(croppedFile.path);
      photo = XFile(croppedFile.path);
      String path =
          (await path_provider.getApplicationDocumentsDirectory()).path;
      String name = basename(photo!.path);
      await photo!.saveTo("$path/$name");
    }

    savedPhoto = Image.file(
      File(imageFile.path),
      height: 200,
      width: 200,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    carregarDados();
    getLostData();
  }

  Future carregarDados() async {
    setState(() {
      carregando = true;
    });

    if (widget.contatoId != null) {
      var contatos = await service.get(widget.contatoId);
      if (contatos.results!.isNotEmpty) {
        contato = contatos.results![0];
        nomeController.text = contato!.nome ?? "";
        emailController.text = contato!.email ?? "";
        telefoneController.text = contato!.telefone ?? "";
        tipoContato = contato!.tipoTelefone ?? "Pessoal";
        if (contato!.caminhoFoto != null && contato!.caminhoFoto!.isNotEmpty) {
          File imageFile = File(contato!.caminhoFoto!);
          if (imageFile.existsSync()) {
            savedPhoto = Image.file(imageFile, width: 200, height: 200);
          }
        }
      }
      setState(() {});
    }

    setState(() {
      carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text("Contato"),
              centerTitle: true,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),
            body: carregando
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      color: Colors.amber,
                      child: ListView(children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (_) {
                                            return Wrap(children: [
                                              ListTile(
                                                leading: const Icon(
                                                    Icons.photo_camera),
                                                title: const Text("Câmera"),
                                                onTap: () async {
                                                  final ImagePicker picker =
                                                      ImagePicker();

                                                  photo =
                                                      await picker.pickImage(
                                                          source: ImageSource
                                                              .camera);
                                                  if (photo != null) {
                                                    String path =
                                                        (await path_provider
                                                                .getApplicationDocumentsDirectory())
                                                            .path;
                                                    String name =
                                                        basename(photo!.path);
                                                    await photo!
                                                        .saveTo("$path/$name");

                                                    await GallerySaver
                                                        .saveImage(photo!.path);
                                                    if (mounted) {
                                                      Navigator.pop(context);
                                                    }
                                                    cropImage(photo!);
                                                    setState(() {});
                                                  }
                                                },
                                              ),
                                              ListTile(
                                                leading:
                                                    const Icon(Icons.photo),
                                                title: const Text("Galeria"),
                                                onTap: () async {
                                                  final ImagePicker picker =
                                                      ImagePicker();

                                                  photo =
                                                      await picker.pickImage(
                                                          source: ImageSource
                                                              .gallery);
                                                  if (mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                  cropImage(photo!);
                                                  setState(() {});
                                                },
                                              )
                                            ]);
                                          });
                                    },
                                    child: savedPhoto ??
                                        Image.asset(
                                          AppImages.user,
                                          height: 200,
                                          width: 200,
                                        ),
                                  ),
                                ],
                              ),
                              const Row(
                                children: [
                                  Text("Tipo de contato"),
                                ],
                              ),
                              Row(
                                children: [
                                  DropdownButton(
                                    isExpanded: false,
                                    isDense: true,
                                    value: tipoContato,
                                    items: tiposContato,
                                    onChanged: (value) {
                                      setState(() {
                                        tipoContato = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              TextField(
                                controller: nomeController,
                                decoration:
                                    const InputDecoration(label: Text("Nome")),
                              ),
                              TextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration:
                                    const InputDecoration(label: Text("Email")),
                              ),
                              TextField(
                                keyboardType: TextInputType.number,
                                controller: telefoneController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TelefoneInputFormatter()
                                ],
                                decoration: const InputDecoration(
                                    label: Text("Telefone")),
                              ),
                              const SizedBox(
                                height: 80,
                              ),
                              Visibility(
                                  visible: (contato != null &&
                                      contato!.objectId != null &&
                                      contato!.objectId!.isNotEmpty),
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStatePropertyAll(
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .inversePrimary)),
                                      onPressed: () async {
                                        try {
                                          var succesOnUpdate =
                                              createOrUpdateContato();
                                          if (succesOnUpdate) {
                                            await service.put(contato!);
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Contato editado com sucesso!"),
                                                elevation: 8,
                                                backgroundColor: Colors.green,
                                              ));
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              bc) =>
                                                          const HomePage()));
                                            }
                                          } else {
                                            if (mounted) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Erro ao editar contato. Verifique campos preenchidos."),
                                                elevation: 8,
                                                backgroundColor: Colors.red,
                                              ));
                                              return;
                                            }
                                          }
                                        } catch (e) {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                              content:
                                                  Text("ERRO: ${e.toString()}"),
                                              elevation: 8,
                                              backgroundColor: Colors.red,
                                            ));
                                            return;
                                          }
                                        }
                                      },
                                      child: const Text("Editar"))),
                              Visibility(
                                visible: contato == null,
                                child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .inversePrimary)),
                                    onPressed: () async {
                                      try {
                                        var succesOnCreate =
                                            createOrUpdateContato();
                                        if (succesOnCreate) {
                                          await service.post(contato!);
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Contato criado com sucesso!"),
                                              elevation: 8,
                                              backgroundColor: Colors.green,
                                            ));
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                    builder:
                                                        (BuildContext bc) =>
                                                            const HomePage()));
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Erro ao criar contato. Verifique campos preenchidos."),
                                              elevation: 8,
                                              backgroundColor: Colors.red,
                                            ));
                                            return;
                                          }
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content:
                                                Text("ERRO: ${e.toString()}"),
                                            elevation: 8,
                                            backgroundColor: Colors.red,
                                          ));
                                          return;
                                        }
                                      }
                                    },
                                    child: const Text("Salvar")),
                              ),
                            ]),
                      ]),
                    ),
                  )));
  }
}
