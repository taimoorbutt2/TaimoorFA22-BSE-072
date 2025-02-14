#include <iostream>
#include <vector>
#include <cstdlib>
#include <ctime>

struct Member {
    std::string name;
    bool hasReceived;
};

class Committee {
private:
    std::vector<Member> members;
    int contribution;
    int currentMonth;

public:
    Committee(int contributionAmount) : contribution(contributionAmount), currentMonth(0) {
        std::srand(std::time(0));
    }

    void addMember(const std::string& name) {
        members.push_back({name, false});
    }

    void runCycle() {
        while (!allMembersReceived()) {
            currentMonth++;
            std::cout << "Month " << currentMonth << std::endl;
            int winnerIndex = drawWinner();
            members[winnerIndex].hasReceived = true;
            std::cout << "Winner: " << members[winnerIndex].name << std::endl;
            std::cout << "Total Amount: " << contribution * members.size() << std::endl;
            std::cout << std::endl;
        }
    }

private:
    bool allMembersReceived() {
        for (const auto& member : members) {
            if (!member.hasReceived) {
                return false;
            }
        }
        return true;
    }

    int drawWinner() {
        std::vector<int> eligibleIndexes;
        for (int i = 0; i < members.size(); ++i) {
            if (!members[i].hasReceived) {
                eligibleIndexes.push_back(i);
            }
        }
        int randomIndex = std::rand() % eligibleIndexes.size();
        return eligibleIndexes[randomIndex];
    }
};

int main() {
    int contributionAmount;
    int numMembers;

    std::cout << "Enter the contribution amount: ";
    std::cin >> contributionAmount;

    std::cout << "Enter the number of members: ";
    std::cin >> numMembers;

    Committee committee(contributionAmount);

    for (int i = 0; i < numMembers; ++i) {
        std::string name;
        std::cout << "Enter the name of member " << i + 1 << ": ";
        std::cin >> name;
        committee.addMember(name);
    }

    committee.runCycle();

    return 0;
}
