# Анализ потоков данных (Def-Use)

Нумерация строк (без пустых строк):

```
1  def process_transaction(user_id, amount, db_connection):
2      log_entry = "Start processing"
3      if amount > 0:
4          status = "approved"
5          balance = get_balance(user_id)
6          new_balance = balance - amount
7          update_balance(user_id, new_balance)
8      log_entry = "Transaction finished with status: " + status
9      file = open("audit_log.txt", "w")
10     file.write(log_entry)
11     return status
```

| Переменная | Def | Use |
|---|---|---|
| log_entry | 2 ("Start processing"), 8 (новая строка) | 10 (file.write). Значение из строки 2 нигде не читается |
| status | 4 ("approved") | 8 (конкатенация), 11 (return) |
| balance | 5 (get_balance) | 6 (вычитание) |
| new_balance | 6 | 7 (update_balance) |
| file | 9 (open) | 10 (file.write). Закрытия нет |

## Дефекты

1. **Неинициализированная переменная.** `status` определяется только
   внутри `if amount > 0` (стр. 4), но используется на стр. 8 и 11
   безусловно. При `amount <= 0` ветка пропускается и возникает
   `UnboundLocalError`.
2. **Мёртвое присваивание.** `log_entry = "Start processing"` (стр. 2)
   всегда перезаписывается на стр. 8 без чтения.
3. **Утечка ресурса.** Файл открыт на стр. 9, `file.close()` не вызывается.
   Данные могут остаться в буфере, дескриптор не освобождается.
