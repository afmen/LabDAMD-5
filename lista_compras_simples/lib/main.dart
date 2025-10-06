import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('lista_compras');

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

// ===== Modelo do Item =====
class ItemCompra {
  String nome;
  String categoria;
  bool comprado;

  ItemCompra({required this.nome, required this.categoria, this.comprado = false});

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'categoria': categoria,
        'comprado': comprado,
      };

  factory ItemCompra.fromMap(Map map) => ItemCompra(
        nome: map['nome'],
        categoria: map['categoria'],
        comprado: map['comprado'] ?? false,
      );
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  List<ItemCompra> itensCompra = [];
  TextEditingController controladorTexto = TextEditingController();
  String categoriaSelecionada = 'Geral';
  final List<String> categorias = ['Geral', 'Frutas', 'Hortifruti', 'Laticínios', 'Carnes', 'Bebidas'];
  final box = Hive.box('lista_compras');
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // ===== Busca e filtro =====
  String filtroBusca = '';
  String filtroCategoria = 'Todas';

  List<ItemCompra> get itensFiltrados {
    return itensCompra.where((item) {
      final matchNome = item.nome.toLowerCase().contains(filtroBusca.toLowerCase());
      final matchCategoria = filtroCategoria == 'Todas' || item.categoria == filtroCategoria;
      return matchNome && matchCategoria;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _inicializarHive();
  }

  void _inicializarHive() async {
    await Hive.openBox('lista_compras');
    _carregarLista();
  }

  // ===== Persistência com Hive =====
  void _salvarLista() {
    final listaMap = itensCompra.map((item) => item.toMap()).toList();
    box.put('itens_compra', listaMap);
  }

  void _carregarLista() {
    final listaMap = box.get('itens_compra');
    if (listaMap != null) {
      setState(() {
        itensCompra = (listaMap as List)
            .map((e) => ItemCompra.fromMap(Map<String, dynamic>.from(e)))
            .toList();
      });
    }
  }

  // ===== Interface =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Lista de Compras'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _compartilharLista,
            tooltip: 'Compartilhar lista',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: limparLista,
            tooltip: 'Limpar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          // Adicionar itens com categoria
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: controladorTexto,
                    decoration: const InputDecoration(
                      hintText: 'Digite um item para comprar...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.add_shopping_cart),
                    ),
                    onSubmitted: (_) => adicionarItem(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: categoriaSelecionada,
                    items: categorias.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoriaSelecionada = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: adicionarItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Busca e filtro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar item...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (valor) {
                      setState(() {
                        filtroBusca = valor;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    value: filtroCategoria,
                    items: ['Todas', ...categorias]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (valor) {
                      setState(() {
                        filtroCategoria = valor!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Estatísticas
          if (itensCompra.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _criarEstatistica('Total', '${itensCompra.length}', Icons.list, Colors.blue),
                  _criarEstatistica('Comprados', '${itensCompra.where((c) => c.comprado).length}', Icons.check_circle, Colors.green),
                  _criarEstatistica('Restantes', '${itensCompra.where((c) => !c.comprado).length}', Icons.pending, Colors.orange),
                ],
              ),
            ),

          // Lista de itens
          Expanded(
            child: itensCompra.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text('Sua lista está vazia!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Text('Adicione itens para começar suas compras', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                : filtroBusca.isNotEmpty || filtroCategoria != 'Todas'
                    ? ListView.builder(
                        itemCount: itensFiltrados.length,
                        itemBuilder: (context, indice) {
                          final item = itensFiltrados[indice];
                          return _construirItem(item, indice);
                        },
                      )
                    : AnimatedList(
                        key: _listKey,
                        initialItemCount: itensCompra.length,
                        itemBuilder: (context, indice, animation) {
                          final item = itensCompra[indice];
                          return SlideTransition(
                            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
                            child: FadeTransition(
                              opacity: animation,
                              child: _construirItem(item, indice),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _construirItem(ItemCompra item, int indice) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: item.comprado ? Colors.green[50] : Colors.white,
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: item.comprado,
            onChanged: (valor) => marcarComoComprado(indice, valor ?? false),
          ),
          title: Text(item.nome, style: TextStyle(decoration: item.comprado ? TextDecoration.lineThrough : null)),
          subtitle: Text(item.categoria, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => removerItemComAnimacao(indice)),
        ),
      ),
    );
  }

  Widget _criarEstatistica(String titulo, String valor, IconData icone, Color cor) {
    return Column(
      children: [
        Icon(icone, color: cor, size: 24),
        const SizedBox(height: 4),
        Text(valor, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
        Text(titulo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void adicionarItem() {
    String nome = controladorTexto.text.trim();
    if (nome.isEmpty) return;

    if (itensCompra.any((e) => e.nome == nome)) {
      _mostrarMensagem('Este item já está na sua lista!');
      return;
    }

    final novoItem = ItemCompra(nome: nome, categoria: categoriaSelecionada);
    setState(() {
      itensCompra.add(novoItem);
      controladorTexto.clear();
      _listKey.currentState?.insertItem(itensCompra.length - 1);
    });

    _salvarLista();
    _mostrarMensagem('Item "$nome" adicionado!');
  }

  void removerItemComAnimacao(int indice) {
    final removedItem = itensCompra[indice];

    _listKey.currentState?.removeItem(
      indice,
      (context, animation) => SlideTransition(
        position: Tween<Offset>(begin: Offset.zero, end: const Offset(1, 0)).animate(animation),
        child: FadeTransition(
          opacity: animation,
          child: Card(child: ListTile(title: Text(removedItem.nome))),
        ),
      ),
      duration: const Duration(milliseconds: 300),
    );

    setState(() {
      itensCompra.removeAt(indice);
    });

    _salvarLista();
    _mostrarMensagem('Item "${removedItem.nome}" removido!');
  }

  void marcarComoComprado(int indice, bool comprado) {
    setState(() {
      itensCompra[indice].comprado = comprado;
    });
    _salvarLista();
    _mostrarMensagem(comprado ? 'Item comprado!' : 'Item desmarcado!');
  }

  void limparLista() {
    if (itensCompra.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Lista'),
        content: const Text('Tem certeza que deseja remover todos os itens?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              for (int i = itensCompra.length - 1; i >= 0; i--) {
                removerItemComAnimacao(i);
              }
              Navigator.of(context).pop();
              _mostrarMensagem('Lista limpa!');
            },
            child: const Text('Limpar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem), duration: const Duration(seconds: 2)),
    );
  }

  void _compartilharLista() {
    if (itensCompra.isEmpty) {
      _mostrarMensagem('Lista vazia — nada para compartilhar.');
      return;
    }

    final texto = itensCompra.asMap().entries.map((e) {
      final idx = e.key + 1;
      final status = e.value.comprado ? '✅' : '🛒';
      return '$idx. $status ${e.value.nome} (${e.value.categoria})';
    }).join('\n');

    // Usando a nova API SharePlus
    SharePlus.instance.share(
      ShareParams(
        text: texto,
        subject: 'Minha Lista de Compras',
      ),
    );
  }

  @override
  void dispose() {
    controladorTexto.dispose();
    super.dispose();
  }
}
