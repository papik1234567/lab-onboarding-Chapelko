#include <iostream>
#include <cstdlib>
#include <ctime>
using namespace std;

int main()
{
    // Инициализация генератора случайных чисел
    srand(time(0));

    char answer; // Ответ пользователя

    do {
        // Три случайных числа от 0 до 9
        int num1 = rand() % 10;
        int num2 = rand() % 10;
        int num3 = rand() % 10;

        cout << "\n=== ИГРОВОЙ АВТОМАТ ===" << endl;
        cout << "Выпавшие числа: " << num1 << " | " << num2 << " | " << num3 << endl;

        // Проверка условия выигрыша
        if (num1 == 7 || num2 == 7 || num3 == 7) {
            cout << "🎰 Счастливая семерка! Вы выиграли!" << endl;
        } else {
            cout << "Попробуйте еще раз." << endl;
        }

        cout << "\nКрутить еще раз? (y/n): ";
        cin >> answer;
    } while (answer == 'y' || answer == 'Y');

    cout << "Спасибо за игру!" << endl;
    return 0;
}
