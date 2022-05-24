import 'dart:io';

class TodoManager {
  File storage;
  Map todos = {};


  TodoManager({ required this.storage }) {
    checkExistsStorage();
    todos = getTodosFromStorage();
  }

  void checkExistsStorage() {
    if(! storage.existsSync()) {
        storage.createSync();
    }
  }

  Map getTodosFromStorage() {
    return { ...storage.readAsLinesSync().asMap() };
  }

  void addTodo({ required String text}) {
      storage.writeAsStringSync(text + "\n" , mode: FileMode.append);
  }

  dynamic removeTodo({ required int id }) {
    if(todos[id] == null){
       printWarning('item not found!');
       return false;
    }
    todos.remove(id);
    refreshTodosInStorage();
    return true;
  }

  dynamic updateTodo({ required int id , required String newText }) {
    todos = todos.map((key , value) => key == id ? MapEntry(key, newText) : MapEntry(key, value));
    refreshTodosInStorage();
  }

  dynamic find({ required int id}) {
      return todos[id] ?? printWarning('item not found!');
  }

  void refreshTodosInStorage() {
    storage.writeAsStringSync("");
    todos.forEach((key, value) => storage.writeAsStringSync(value + "\n" , mode: FileMode.append) );
  }

  void flushTodos(){
    storage.writeAsStringSync("");  
  }


}


class CommandManager {
  Map<int , String> commands;

  CommandManager({ required this.commands});

  String getCommand(int key) {
    return commands[key] ?? "";
  }

  void printHelper() {
    printWarning("""
\n
Todo App Commands : 
  --add, -a  [title] : string               "add a text to Todos List"
  --find, -f [id] : int                     "find a todo and return the text"
  --update, -u [id] : int  [title] : string  "update a todo"
  --delete, -d  [id] : int                   "delete a todo"
  --list, -l                                 "show Todos List"
  --flush, -F                                "flush all Todos List"
  --help, -h                                 "show commands list"
      """);
  }

  bool checkCommandExists(int key, { required String Function() message }) {
    if(commands[key] != null)  {
      return true;
    }

    printError(message());
    printHelper();
    return false;
  }
}

void main(List<String> arguments) {


  TodoManager todoManager = TodoManager(storage: File("./todos.txt"));
  CommandManager commandManager = CommandManager(commands: arguments.asMap() );

  switch (commandManager.getCommand(0)) {
    case '--add':
    case '-a' :

      if(! commandManager.checkCommandExists(1 , message : () => "please enter a title")) {
        break;
      }

      todoManager.addTodo(text : commandManager.getCommand(1) );
   
      printSuccess("the todo add successfully");
    break;
    case '--list':
    case '-l':
      todoManager.getTodosFromStorage().forEach((key, value) => print("$key : $value"));
      break;
    case '--delete':
    case '-d':

        if(! commandManager.checkCommandExists(1 , message : () => "please enter an id")) {
          break;
        }

          if(todoManager.removeTodo(id : int.parse( commandManager.getCommand(1) ) )){
            printSuccess("the todo delete successfully");

          }
        break;

    case '--update':
    case '-u' : 
        if(! commandManager.checkCommandExists(1 , message : () => "please enter an id")) {
          break;
        }

        if(! commandManager.checkCommandExists(2 , message : () => "please enter a new title")) {
          break;
        }
      
        todoManager.updateTodo(
          id: int.parse( commandManager.getCommand(1) ),
          newText: commandManager.getCommand(2)
        );
    
        printSuccess("the todo updated successfully");

      break;


    case '--find':
    case '-f':
        if(! commandManager.checkCommandExists(1 , message : () => "please enter an id")) {
          break;
        }
        
        printSuccess(todoManager.find(id : int.parse( commandManager.getCommand(1) ) ) );
      break;
    case '--flush':
    case '-F':

      todoManager.flushTodos();
      printSuccess("the todos list flush successfully");

    break;

    default:
        commandManager.printHelper();
  }
}

void printWarning(String text) {
  print('\x1B[33m $text \x1B[0m');
}

void printError(String text) {
  print('\x1B[31m--->!!! $text !!!<---\x1B[0m');
}

void printSuccess(String text) {
  print('\x1B[32m---> $text\x1B[0m');
}

