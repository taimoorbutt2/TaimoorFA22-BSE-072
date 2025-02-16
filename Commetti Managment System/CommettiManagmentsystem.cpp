#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>
#include <map>
#include <set>
#include <algorithm>

#ifdef _WIN32
#include <windows.h>
#endif

using namespace std;

struct Member {
    int id;  // System-generated Unique ID
    string name;
    bool hasReceived;
    double amountPaid;
    double receivedAmount; // NEW: Tracks amount received
};

// Global variables
vector<Member> members;
map<int, double> payments;
set<int> usedIds; // To ensure unique IDs
int totalMembers = 0;
double monthlyContribution = 0.0;
bool cycleCompleted = false;

// Function to clear the screen based on OS
void clearScreen() {
#ifdef _WIN32
    system("CLS"); // Clear screen on Windows
#else
    system("clear"); // Clear screen on Linux/macOS
#endif
}

// Function to generate a unique 4-digit ID
int generateUniqueId() {
    int newId;
    do {
        newId = 1000 + rand() % 9000; // Generates a number between 1000-9999
    } while (usedIds.find(newId) != usedIds.end()); // Ensure ID is unique
    usedIds.insert(newId);
    return newId;
}

// Function to add multiple members at once
void addMembers() {
    clearScreen();
    int count;
    cout << "--- Add Members ---\n";
    cout << "Enter the number of members to add: ";
    cin >> count;

    for (int i = 0; i < count; i++) {
        Member m;
        cout << "Enter Member Name " << (i + 1) << ": ";
        cin >> m.name;

        m.id = generateUniqueId();  // Assign system-generated unique ID
        m.hasReceived = false;
        m.amountPaid = 0.0;
        m.receivedAmount = 0.0; // Initialize received amount
        members.push_back(m);
        totalMembers++;

        // Display the assigned ID
        cout << "Member added! Name: " << m.name << " | Unique ID: " << m.id << endl;
    }
}

// Function to set the monthly contribution
void setMonthlyContribution() {
    clearScreen();
    cout << "--- Set Monthly Contribution ---\n";
    cout << "Enter the fixed monthly contribution amount: ";
    cin >> monthlyContribution;
    cout << "Monthly contribution set to $" << monthlyContribution << endl;
}

// Function to track payments
void makePayment() {
    clearScreen();
    cout << "--- Make Payment ---\n";
    int id;
    cout << "Enter Member Unique ID for payment: ";
    cin >> id;

    auto it = find_if(members.begin(), members.end(), [id](Member &m) { return m.id == id; });

    if (it != members.end()) {
        it->amountPaid += monthlyContribution;
        payments[id] += monthlyContribution;
        cout << it->name << " (ID: " << it->id << ") has paid $" << monthlyContribution << endl;
    } else {
        cout << "Member not found! Please check the Unique ID." << endl;
    }
}

// Function to conduct a lucky draw
void luckyDraw() {
    clearScreen();
    cout << "--- Lucky Draw ---\n";
    vector<Member *> eligibleMembers;
    
    // Get all members who haven't received money yet
    for (auto &m : members) {
        if (!m.hasReceived) {
            eligibleMembers.push_back(&m);
        }
    }

    if (eligibleMembers.empty()) {
        cout << "All members have received their share. The cycle is complete!" << endl;
        cycleCompleted = true;
        return;
    }

    srand(time(0));
    int winnerIndex = rand() % eligibleMembers.size();
    Member *winner = eligibleMembers[winnerIndex];

    winner->hasReceived = true;
    double receivedAmount = totalMembers * monthlyContribution;
    winner->receivedAmount += receivedAmount; // NEW: Track received amount

    cout << "Congratulations! " << winner->name << " (ID: " << winner->id 
         << ") has won the collected amount of $" << receivedAmount << endl;

    // Reset the cycle if all members have received their amount
    bool allReceived = all_of(members.begin(), members.end(), [](Member &m) { return m.hasReceived; });

    if (allReceived) {
        cout << "The cycle has completed. Restarting a new round..." << endl;
        for (auto &m : members) {
            m.hasReceived = false;
        }
        cycleCompleted = false;
    }
}

// Function to display members
void showMembers() {
    clearScreen();
    cout << "--- Member List ---\n";
    for (const auto &m : members) {
        cout << "ID: " << m.id << " | Name: " << m.name 
             << " | Paid: $" << m.amountPaid
             << " | Received: $" << m.receivedAmount << endl; // NEW: Show received amount
    }
}

// Function to show the main menu dynamically
void showMenu() {
    int choice;
    do {
        clearScreen();
        cout << "--- Commetti Management System ---\n";
        cout << "1. Add Members\n";
        cout << "2. Set Monthly Contribution\n";
        cout << "3. Make Payment\n";
        cout << "4. Conduct Lucky Draw\n";
        cout << "5. Show Members\n";
        cout << "6. Exit\n";
        cout << "Enter your choice: ";
        cin >> choice;

        switch (choice) {
            case 1: addMembers(); break;
            case 2: setMonthlyContribution(); break;
            case 3: makePayment(); break;
            case 4: luckyDraw(); break;
            case 5: showMembers(); break;
            case 6: cout << "Exiting program...\n"; break;
            default: cout << "Invalid choice, try again.\n";
        }

        // Wait for user before going back to the main menu
        if (choice != 6) {
            cout << "\nPress Enter to return to the main menu...";
            cin.ignore();
            cin.get();
        }
    } while (choice != 6);
}

// Main function
int main() {
    srand(time(0)); // Seed for unique ID and lucky draw randomness
    showMenu();
    return 0;
}
