# BACKUP REPOS

## Что это такое?

Набор скриптов для резервного копирования и зеркалирования Git репозиториев.

## Скрипт `repo-backup.sh`

Скрипт для резервного копирования репозиториев с облачных сервисов (таких как GitHub, GitLab и аналогов). На вход принимает файл со списком репозиториев, формат файла простой, каждая строка является ссылкой на репозиторий. По умолчанию скрипт не удаляет ранее клонированные репозитории, при последующих запусках скрипт будет делать для нмх `pull`. Если хранение репозиториев не требуется, то можно указать скрипту опцию `-r` и по окончании работы, он удалит ранее клонированные репозитории.

### Примеры использования

Самым простым вариантом запуска является такой (`*.list` надо подготовить заранее):

```
repo-backup.sh -l github.list
```

В результате работы скрипта будет создан архив формата `backup-YYYY-MM-DD-HHMMSS.tar.gz` в котором бдут все клонированные репозитории из файла `github.list`.

Имя выходного архива можно задать с помощью опции `-o`:

```
repo-backup.sh -l github.list -o test.tar.gz
```

### Параметры 
`-l` | `--list` - файл со списком репозиториев которые нужно упаковать в архив.

`-d` |`--dest` - каталог в который будет производиться клонирование, по умолчанию значение `backup`.

`-o` | `--out` - имя архива, значение по умолчанию: `backup-YYYY-MM-DD-HHMMSS.tar.gz`, где `YYYY-MM-DD-HHMMSS` заменяется на текущие год, месяц, день, час, минуты и секунды.

`-r` | `--rm` - удалить клонированные репозитории после архивации.

## Скрипт `repo-mirror.sh`

Скрипт для зеркалирования git репозиториев. Как и предыдущий скрипт может принимать на вход список с репозиториями, но помимо этого может произвести зеркалирование одного репозитория через передачу параметров.

### Примеры использования

Запуск зеркалирования через заранее подготовленный список:

```
repo-mirror.sh -l repo.list
```

Такой вариант запуска лучше использовать для автоматического зеркалирования например через `cron`. Формат файла со списком репозиториев описан ниже.

Для разовой операции можете передать исходный и конечный репозитории в командной строке, например так:

```
repo-mirror.sh -s git@github.com:cyfive/backup-repos.git -d git@gitflic.ru:cyfive/backup-repos.git
```

### Параметры 
`-l` | `--list` - файл со списком репозиториев для зеркалирования, формат файла следующий:

```
<репозиторий источник>;<репозиторий назначение>
```

Все пробелы в строках очищаются.

Пример валидного файла:

```
git@github.com:cyfive/backup-repos.git;git@gitflic.ru:cyfive/backup-repos.git
```

`-c` | `--cache` - путь к временному каталогу в который будет производиться промежуточное клонирование репозитория. Значение по умолчанию: `.cache`. По окончании работы каталог удаляется.

`-s` | `--src` - репозиторий исходник для разового зеркалирования.

`-d` | `--dst` - репозиторий назначения для разового зеркалирования.
