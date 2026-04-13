class Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final int tier;

  const Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.tier,
  });
}

class QuestionBank {
  static final List<Question> _all = [
    // Tier 1 - Flutter Basics
    const Question(
      prompt: 'Em que ano o Flutter foi anunciado pela primeira vez?',
      options: ['2015', '2017', '2018', '2016'],
      correctIndex: 1,
      explanation: 'Flutter foi anunciado em 2015 no Dart Developer Summit.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual empresa criou o Flutter?',
      options: ['Facebook', 'Google', 'Apple', 'Microsoft'],
      correctIndex: 1,
      explanation: 'Google desenvolveu o Flutter como um framework open-source.',
      tier: 1,
    ),
    const Question(
      prompt: 'Flutter usa qual linguagem de programação?',
      options: ['Kotlin', 'Swift', 'Dart', 'Java'],
      correctIndex: 2,
      explanation: 'Dart é a linguagem oficial usada no desenvolvimento com Flutter.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual é o widget básico em Flutter que cria uma coluna?',
      options: ['Row', 'Column', 'Stack', 'Container'],
      correctIndex: 1,
      explanation: 'Column organiza widgets verticalmente, Row organiza horizontalmente.',
      tier: 1,
    ),
    const Question(
      prompt: 'O que permite Flutter funcionar em múltiplas plataformas?',
      options: ['WebView', 'Mecanismo de renderização Skia', 'JVM', 'LLVM'],
      correctIndex: 1,
      explanation: 'Flutter usa Skia para renderização rápida em todas as plataformas.',
      tier: 1,
    ),
    const Question(
      prompt: 'Qual versão do Flutter introduziu suporte para web?',
      options: ['1.5', '1.9', '1.20', '2.0'],
      correctIndex: 2,
      explanation: 'Flutter 1.20 trouxe suporte experimental para web.',
      tier: 1,
    ),
    const Question(
      prompt: 'O Dart é estaticamente digitado?',
      options: ['Nunca', 'Opcionalmente (sound null safety)', 'Apenas em web', 'Apenas em Android'],
      correctIndex: 1,
      explanation: 'Dart oferece digitação estática opcional com null safety.',
      tier: 1,
    ),
    const Question(
      prompt: 'Quantas plataformas diferentes o Flutter suporta?',
      options: ['2 (iOS e Android)', '4', '6', 'Apenas móvel'],
      correctIndex: 2,
      explanation: 'Flutter suporta iOS, Android, Web, Desktop (Windows, Mac, Linux).',
      tier: 1,
    ),

    // Tier 2 - Mobile History
    const Question(
      prompt: 'Qual foi o primeiro smartphone?',
      options: ['iPhone', 'BlackBerry', 'Simon', 'Nokia 9000'],
      correctIndex: 2,
      explanation: 'Simon, lançado em 1992, é considerado o primeiro smartphone.',
      tier: 2,
    ),
    const Question(
      prompt: 'Em que ano foi lançado o primeiro iPhone?',
      options: ['2005', '2007', '2008', '2006'],
      correctIndex: 1,
      explanation: 'Steve Jobs apresentou o iPhone em junho de 2007.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual sistema operacional mobile foi lançado primeiro?',
      options: ['iOS', 'Android', 'Windows Mobile', 'Symbian'],
      correctIndex: 2,
      explanation: 'Windows Mobile foi o primeiro, mas Android foi o primeiro open-source.',
      tier: 2,
    ),
    const Question(
      prompt: 'Quantos cores tinha o iPhone original?',
      options: ['Nenhum (preto e branco)', 'Variante de cinza', '8 cores', '256 cores'],
      correctIndex: 0,
      explanation: 'O iPhone original tinha uma tela monocromática antes do 3G.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual foi a primeira versão do Android?',
      options: ['Android 1.0', 'Android 2.0', 'Android 1.5', 'Android 1.6'],
      correctIndex: 0,
      explanation: 'Android 1.0 foi lançado em setembro de 2008.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual é a resolução do iPhone original?',
      options: ['320x240', '480x320', '640x960', '240x160'],
      correctIndex: 1,
      explanation: 'iPhone original tinha 480x320 pixels a 163 PPI.',
      tier: 2,
    ),
    const Question(
      prompt: 'Quando surgiu o Touch ID nos iPhones?',
      options: ['2012', '2013', '2014', '2015'],
      correctIndex: 2,
      explanation: 'iPhone 5S em 2013 introduziu Touch ID.',
      tier: 2,
    ),
    const Question(
      prompt: 'Qual smartphone foi o primeiro com NFC?',
      options: ['iPhone 6', 'Samsung Galaxy S3', 'Nokia N9', 'Samsung Galaxy Nexus'],
      correctIndex: 2,
      explanation: 'Nokia N9 foi um dos primeiros com NFC em 2011.',
      tier: 2,
    ),

    // Tier 3 - Flutter Advanced
    const Question(
      prompt: 'O que é um StatefulWidget em Flutter?',
      options: [
        'Widget que não muda',
        'Widget que pode mudar de estado durante seu ciclo de vida',
        'Widget importado de pacotes',
        'Widget que só funciona web'
      ],
      correctIndex: 1,
      explanation: 'StatefulWidget pode mudar seu estado interno chamando setState().',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é o método chamado quando um Widget é criado?',
      options: ['build()', 'initState()', 'dispose()', 'didChangeDependencies()'],
      correctIndex: 1,
      explanation: 'initState() é chamado uma vez quando o State é criado.',
      tier: 3,
    ),
    const Question(
      prompt: 'Para que serve o Provider em Flutter?',
      options: [
        'Gerenciar estado de forma simples e reativa',
        'Fazer requisições HTTP',
        'Desenhar em Canvas',
        'Compilar código'
      ],
      correctIndex: 0,
      explanation: 'Provider é uma biblioteca popular para gerenciamento de estado reativo.',
      tier: 3,
    ),
    const Question(
      prompt: 'O que é Hot Reload em Flutter?',
      options: [
        'Reiniciar a aplicação completamente',
        'Atualizar código sem perder estado do app',
        'Compilar o APK',
        'Sincronizar com servidor'
      ],
      correctIndex: 1,
      explanation: 'Hot Reload permite desenvolvimento rápido injecting código sem reiniciar.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual widget Flutter cria um layout de grade?',
      options: ['GridView', 'Table', 'Row', 'Wrap'],
      correctIndex: 0,
      explanation: 'GridView cria uma grade responsiva de widgets.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é o objetivo do BuildContext?',
      options: [
        'Executar código assíncrono',
        'Referenciar a posição do widget na árvore',
        'Armazenar dados localmente',
        'Compilar layouts'
      ],
      correctIndex: 1,
      explanation: 'BuildContext referencia a posição do widget na árvore de widgets.',
      tier: 3,
    ),
    const Question(
      prompt: 'O que faz o método didUpdateWidget?',
      options: [
        'Atualiza o estado quando o widget é reconstruído',
        'Destroi o widget',
        'Inicia o widget',
        'Renderiza a tela'
      ],
      correctIndex: 0,
      explanation: 'didUpdateWidget é chamado quando o widget que contém o state é atualizado.',
      tier: 3,
    ),
    const Question(
      prompt: 'Qual é a diferença entre Scaffold e Container?',
      options: [
        'Não há diferença',
        'Scaffold fornece estrutura completa de app com AppBar, Drawer, etc',
        'Container é para desktop apenas',
        'Scaffold não pode ter children'
      ],
      correctIndex: 1,
      explanation: 'Scaffold é uma classe que implementa a estrutura visual do Material Design.',
      tier: 3,
    ),

    // Tier 4 - Mobile Evolution
    const Question(
      prompt: 'Quantos anos levou entre o primeiro iPhone e o 5G em smartphones?',
      options: ['10 anos', '12 anos', '13 anos', '15 anos'],
      correctIndex: 2,
      explanation: 'iPhone foi 2007, primeiros 5G phones foram 2020.',
      tier: 4,
    ),
    const Question(
      prompt: 'Qual smartphone foi o primeiro com câmera de 64MP?',
      options: ['Samsung Galaxy S20', 'Mi 9T Pro', 'Samsung Galaxy S9+', 'OnePlus 7'],
      correctIndex: 1,
      explanation: 'Xiaomi Mi 9T Pro foi pioneiro com 64MP sensor principal.',
      tier: 4,
    ),
    const Question(
      prompt: 'Em que ano foi lançado o Android Market (Google Play)?',
      options: ['2008', '2010', '2012', '2014'],
      correctIndex: 0,
      explanation: 'Android Market foi lançado em 2008, rebatizado como Google Play em 2012.',
      tier: 4,
    ),
    const Question(
      prompt: 'Qual foi a primeira linguagem de programação para apps Android?',
      options: ['Java', 'Kotlin', 'C++', 'Python'],
      correctIndex: 0,
      explanation: 'Java era a única opção oficial até Kotlin ser suportado.',
      tier: 4,
    ),
    const Question(
      prompt: 'Em que ano o Kotlin se tornou linguagem oficial no Android?',
      options: ['2017', '2018', '2019', '2020'],
      correctIndex: 1,
      explanation: 'Google anunciou Kotlin como linguagem oficial em maio de 2019.',
      tier: 4,
    ),
    const Question(
      prompt: 'Qual foi o primeiro smartphone com 1GB de RAM?',
      options: ['HTC Dream', 'HTC Desire', 'Samsung Galaxy S', 'iPhone 4'],
      correctIndex: 1,
      explanation: 'HTC Desire foi um dos primeiros com 1GB de RAM em 2010.',
      tier: 4,
    ),
    const Question(
      prompt: 'Quando foi lançado o primeiro App Store da Apple?',
      options: ['2007', '2008', '2009', '2010'],
      correctIndex: 1,
      explanation: 'App Store foi lançado em julho de 2008 com o iPhone 3G.',
      tier: 4,
    ),
    const Question(
      prompt: 'Qual recurso o iPhone X introduziu que mudou design móvel?',
      options: ['Bateria grande', 'Notch', 'Face ID', 'Todas as anteriores'],
      correctIndex: 3,
      explanation: 'iPhone X trouxe Notch, Face ID e mudou a forma de pensar design móvel.',
      tier: 4,
    ),

    // Tier 5 - Flutter Architecture
    const Question(
      prompt: 'Qual é a estrutura de camadas do Flutter?',
      options: [
        'Framework, Engine, Embedder',
        'Frontend, Backend, Database',
        'UI, Logic, State',
        'Client, Server, Network'
      ],
      correctIndex: 0,
      explanation: 'Flutter tem Framework (Dart), Engine (C++), e Embedders (iOS/Android).',
      tier: 5,
    ),
    const Question(
      prompt: 'O que é o Skia engine no Flutter?',
      options: [
        'Motor JavaScript',
        'Mecanismo de renderização gráfica 2D/3D',
        'Compilador Dart',
        'Banco de dados local'
      ],
      correctIndex: 1,
      explanation: 'Skia é responsável pela renderização rápida de gráficos.',
      tier: 5,
    ),
    const Question(
      prompt: 'Qual padrão arquitetural Flutter recomenda para apps complexos?',
      options: ['MVC', 'BLoC', 'MVVM', 'Todos os anteriores'],
      correctIndex: 3,
      explanation: 'Flutter é flexível e suporta vários padrões, BLoC é popular.',
      tier: 5,
    ),
    const Question(
      prompt: 'O que é a árvore de widgets em Flutter?',
      options: [
        'Uma estrutura de dados em árvore que representa a UI',
        'Um banco de dados',
        'Uma biblioteca de componentes',
        'Um framework CSS'
      ],
      correctIndex: 0,
      explanation: 'A árvore de widgets descreve toda a UI da aplicação recursivamente.',
      tier: 5,
    ),
    const Question(
      prompt: 'Em que linguagem é escrito o Flutter Engine?',
      options: ['Dart', 'C++', 'Java', 'Swift'],
      correctIndex: 1,
      explanation: 'O Engine é implementado principalmente em C++ para performance.',
      tier: 5,
    ),
    const Question(
      prompt: 'O que são renderObjects em Flutter?',
      options: [
        'Widgets da UI',
        'Objetos que realizam layout e renderização',
        'Dados armazenados localmente',
        'Serviços de rede'
      ],
      correctIndex: 1,
      explanation: 'RenderObjects executam layout, painting e hit testing.',
      tier: 5,
    ),
    const Question(
      prompt: 'Qual é a diferença entre Element e RenderObject?',
      options: [
        'Não há diferença',
        'Element gerencia configuração, RenderObject gerencia renderização',
        'Element é apenas para iOS',
        'RenderObject é apenas para Android'
      ],
      correctIndex: 1,
      explanation: 'Element gerencia a configuração, RenderObject gerencia geometria e rendering.',
      tier: 5,
    ),
    const Question(
      prompt: 'O que é Composition over Inheritance em Flutter?',
      options: [
        'Usar herança de classes',
        'Usar widgets aninhados ao invés de herança',
        'Não usar classes',
        'Usar apenas funções'
      ],
      correctIndex: 1,
      explanation: 'Flutter favorece composição de widgets ao invés de herança de classes.',
      tier: 5,
    ),
  ];

  static Question forFloor(int floor, Set<int> usedIndices) {
    final difficulty = _calculateDifficulty(floor);
    final pool = _all
        .asMap()
        .entries
        .where((e) => e.value.tier <= difficulty && !usedIndices.contains(e.key))
        .map((e) => (index: e.key, question: e.value))
        .toList()
      ..shuffle();

    if (pool.isEmpty) {
      usedIndices.clear();
      return (_all.where((q) => q.tier <= difficulty).toList()..shuffle()).first;
    }
    
    usedIndices.add(pool.first.index);
    return pool.first.question;
  }

  static int _calculateDifficulty(int floor) {
    if (floor <= 3) return 1;
    if (floor <= 6) return 2;
    if (floor <= 10) return 3;
    if (floor <= 15) return 4;
    return 5;
  }
}
