import 'dart:io';
import 'dart:math';

class Member {
  int id;
  String name;
  bool hasReceived;
  double amountPaid;
  double receivedAmount;

  Member(this.id, this.name)
      : hasReceived = false,
        amountPaid = 0.0,
        receivedAmount = 0.0;
}

List<Member> members = [];
Map<int, double> payments = {};
Set<int> usedIds = {};
int totalMembers = 0;
double monthlyContribution = 0.0;
bool cycleCompleted = false;

void clearScreen() {
  if (Platform.isWindows) {
    Process.runSync("cls", [], runInShell: true);
  } else {
    print("\x1B[2J\x1B[0;0H");
  }
}

int generateUniqueId() {
  int newId;
  Random random = Random();
  do {
    newId = 1000 + random.nextInt(9000);
  } while (usedIds.contains(newId));
  usedIds.add(newId);
  return newId;
}

void addMembers() {
  clearScreen();
  print("--- Add Members ---");
  stdout.write("Enter the number of members to add: ");
  int count = int.parse(stdin.readLineSync()!);

  for (int i = 0; i < count; i++) {
    stdout.write("Enter Member Name ${i + 1}: ");
    String name = stdin.readLineSync()!;
    int id = generateUniqueId();
    members.add(Member(id, name));
    totalMembers++;
    print("Member added! Name: $name | Unique ID: $id");
  }
}

void setMonthlyContribution() {
  clearScreen();
  print("--- Set Monthly Contribution ---");
  stdout.write("Enter the fixed monthly contribution amount: ");
  monthlyContribution = double.parse(stdin.readLineSync()!);
  print("Monthly contribution set to \$${monthlyContribution.toStringAsFixed(2)}");
}

void makePayment() {
  clearScreen();
  print("--- Make Payment ---");
  stdout.write("Enter Member Unique ID for payment: ");
  int id = int.parse(stdin.readLineSync()!);

  var member = members.firstWhere((m) => m.id == id, orElse: () => Member(-1, ""));
  if (member.id != -1) {
    member.amountPaid += monthlyContribution;
    payments[id] = (payments[id] ?? 0) + monthlyContribution;
    print("${member.name} (ID: ${member.id}) has paid \$${monthlyContribution.toStringAsFixed(2)}");
  } else {
    print("Member not found! Please check the Unique ID.");
  }
}

void luckyDraw() {
  clearScreen();
  print("--- Lucky Draw ---");
  List<Member> eligibleMembers = members.where((m) => !m.hasReceived).toList();

  if (eligibleMembers.isEmpty) {
    print("All members have received their share. The cycle is complete!");
    cycleCompleted = true;
    return;
  }

  Random random = Random();
  Member winner = eligibleMembers[random.nextInt(eligibleMembers.length)];
  winner.hasReceived = true;
  double receivedAmount = totalMembers * monthlyContribution;
  winner.receivedAmount += receivedAmount;

  print("Congratulations! ${winner.name} (ID: ${winner.id}) has won the collected amount of \$${receivedAmount.toStringAsFixed(2)}");

  if (members.every((m) => m.hasReceived)) {
    print("The cycle has completed. Restarting a new round...");
    members.forEach((m) => m.hasReceived = false);
    cycleCompleted = false;
  }
}

void showMembers() {
  clearScreen();
  print("--- Member List ---");
  for (var m in members) {
    print("ID: ${m.id} | Name: ${m.name} | Paid: \$${m.amountPaid.toStringAsFixed(2)} | Received: \$${m.receivedAmount.toStringAsFixed(2)}");
  }
}

void showMenu() {
  while (true) {
    clearScreen();
    print("--- Commetti Management System ---");
    print("1. Add Members");
    print("2. Set Monthly Contribution");
    print("3. Make Payment");
    print("4. Conduct Lucky Draw");
    print("5. Show Members");
    print("6. Exit");
    stdout.write("Enter your choice: ");
    int choice = int.parse(stdin.readLineSync()!);

    switch (choice) {
      case 1:
        addMembers();
        break;
      case 2:
        setMonthlyContribution();
        break;
      case 3:
        makePayment();
        break;
      case 4:
        luckyDraw();
        break;
      case 5:
        showMembers();
        break;
      case 6:
        print("Exiting program...");
        return;
      default:
        print("Invalid choice, try again.");
    }

    print("\nPress Enter to return to the main menu...");
    stdin.readLineSync();
  }
}

void main() {
  Random().nextInt(1); // Initialize randomness
  showMenu();
}
