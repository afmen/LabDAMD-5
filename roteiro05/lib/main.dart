import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PaginaInicial(),
    );
  }
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  // Lista para armazenar os itens
  List<String> itensCompra = [];
  
  // Controlador para o campo de texto
  TextEditingController controladorTexto = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior do app
      appBar: AppBar(
        title: const Text('Minha Lista de Compras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      
      // Corpo principal do app
      body: Column(
        children: [
          // Área para adicionar novos itens
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Campo de texto
                Expanded(
                  child: TextField(
                    controller: controladorTexto,
                    decoration: const InputDecoration(
                      hintText: 'Digite um item...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (texto) => adicionarItem(),
                  ),
                ),
                const SizedBox(width: 8),
                // Botão de adicionar
                ElevatedButton(
                  onPressed: adicionarItem,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          
          // Lista de itens
          Expanded(
            child: itensCompra.isEmpty
                ? const Center(
                    child: Text(
                      'Sua lista está vazia!\nAdicione o primeiro item.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: itensCompra.length,
                    itemBuilder: (context, indice) {
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const Icon(Icons.shopping_cart),
                          title: Text(itensCompra[indice]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => removerItem(indice),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // Informação na parte inferior
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Text(
          'Total de itens: ${itensCompra.length}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Função para adicionar item na lista
  void adicionarItem() {
    String novoItem = controladorTexto.text.trim();
    
    if (novoItem.isNotEmpty) {
      setState(() {
        itensCompra.add(novoItem);
        controladorTexto.clear();
      });
    }
  }

  // Função para remover item da lista
  void removerItem(int indice) {
    setState(() {
      itensCompra.removeAt(indice);
    });
  }

  // Limpar recursos quando o widget for removido
  @override
  void dispose() {
    controladorTexto.dispose();
    super.dispose();
  }
}