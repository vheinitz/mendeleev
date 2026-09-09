import '../data/names.dart';
import '../data/substances.dart';
import '../models/element.dart';
import 'app_settings.dart';

enum AppLanguage { de, en, ru }

AppLanguage get currentLanguage {
  switch (AppSettings.instance.language) {
    case 'en':
      return AppLanguage.en;
    case 'ru':
      return AppLanguage.ru;
    default:
      return AppLanguage.de;
  }
}

/// Übersetzt einen (deutschen) UI-Text in die aktuelle Sprache.
/// Optionale Platzhalter {a}, {b}, ... werden ersetzt.
String tr(String de, [Map<String, String>? args]) {
  var s = de;
  switch (currentLanguage) {
    case AppLanguage.en:
      s = uiEn[de] ?? de;
    case AppLanguage.ru:
      s = uiRu[de] ?? de;
    case AppLanguage.de:
      s = de;
  }
  if (args != null) {
    args.forEach((k, v) => s = s.replaceAll('{$k}', v));
  }
  return s;
}

/// Name eines Elements in der aktuellen Sprache.
String elementName(Element e) {
  switch (currentLanguage) {
    case AppLanguage.en:
      return elementNameEn[e.number] ?? e.nameLa;
    case AppLanguage.ru:
      return elementNameRu[e.number] ?? e.nameLa;
    case AppLanguage.de:
      return e.nameDe;
  }
}

String categoryName(String category) {
  switch (currentLanguage) {
    case AppLanguage.en:
      return categoryEn[category] ?? category;
    case AppLanguage.ru:
      return categoryRu[category] ?? category;
    case AppLanguage.de:
      return category;
  }
}

String substanceName(Substance s) {
  switch (currentLanguage) {
    case AppLanguage.en:
      return substanceNameEn[s.name] ?? s.name;
    case AppLanguage.ru:
      return substanceNameRu[s.name] ?? s.name;
    case AppLanguage.de:
      return s.name;
  }
}

const Map<String, String> uiEn = {
  'Periodensystem Lernprogramm': 'Periodic Table Learning Program',
  'Chemie lernen leicht gemacht!': 'Chemistry made easy!',
  'Periodensystem': 'Periodic Table',
  'Alle Elemente als Tabelle ansehen und nachschlagen': 'View and look up all elements as a table',
  'Quiz & Üben': 'Quiz & Practice',
  'Gruppe, Symbole, Lücken und lateinische Namen': 'Groups, symbols, gaps and Latin names',
  'Molmasse-Rechner': 'Molar Mass Calculator',
  'Molmasse einer chemischen Formel berechnen': 'Calculate the molar mass of a chemical formula',
  'Fehler-Statistik': 'Error Statistics',
  'Problem-Elemente mit rotem Rahmen anzeigen': 'Show problem elements with a red border',
  'Elemente konfigurieren': 'Configure Elements',
  'Auswählen, welche Elemente abgefragt werden': 'Choose which elements are tested',
  'Sprache': 'Language',
  'Einstellungen': 'Settings',
  'Fehler-Statistik anzeigen': 'Show error statistics',
  'Rote Rahmen zeigen Problem-Elemente': 'Red borders mark problem elements',
  'Statistik zurücksetzen': 'Reset statistics',
  'Statistik wurde zurückgesetzt.': 'Statistics have been reset.',
  'Elemente mit Fehlern: {a} · Je dicker der rote Rahmen, desto mehr Probleme.':
      'Elements with errors: {a} · The thicker the red border, the more problems.',
  'Tippe auf ein Element, um es ein- oder auszublenden.\nGraue Elemente werden nicht abgefragt.':
      'Tap an element to show or hide it.\nGray elements are not tested.',
  'Alle': 'All', 'Keine': 'None', 'Wichtige Auswahl': 'Important selection',
  'Aktiv: {a} von {b}': 'Active: {a} of {b}',
  'Gruppe nennen': 'Name the group',
  'Zu einem Element die Gruppe (1–18) finden': 'Find the group (1–18) of an element',
  'Symbol → Name': 'Symbol → Name',
  'Zum Symbol den richtigen Namen finden': 'Find the correct name for the symbol',
  'Name → Symbol': 'Name → Symbol',
  'Zum Namen die richtige Abkürzung finden': 'Find the correct symbol for the name',
  'Lateinische Namen': 'Latin Names',
  'Deutsche und lateinische Namen zuordnen': 'Match names with their Latin names',
  'Lücke füllen': 'Fill the gap',
  'Das fehlende Element zwischen Nachbarn finden': 'Find the missing element between neighbours',
  'Wertigkeit': 'Valence',
  'Die Wertigkeit eines Elements nennen': 'Name the valence of an element',
  'Element → Elektronegativität': 'Element → Electronegativity',
  'Die EN eines Elements nennen': 'Name the EN of an element',
  'Elektronegativität → Element': 'Electronegativity → Element',
  'Zum EN-Wert das Element finden': 'Find the element for an EN value',
  'Element finden': 'Find the Element',
  'Gesuchtes Element in der Tabelle anklicken (Zeit läuft!)': 'Tap the requested element in the table (time is running!)',
  'Stoff → Formel': 'Substance → Formula',
  'Zur Stoffbezeichnung die Formel finden': 'Find the formula for a substance name',
  'Formel → Stoff': 'Formula → Substance',
  'Zur Formel den Stoffnamen finden': 'Find the substance name for a formula',
  'Element → Molmasse': 'Element → Molar Mass',
  'Die Molmasse eines Elements nennen': 'Name the molar mass of an element',
  'Molmasse → Element': 'Molar Mass → Element',
  'Zur Molmasse das Element finden': 'Find the element for a molar mass',
  'Stoffmenge (n, m, M)': 'Amount of substance (n, m, M)',
  'Masse oder Stoffmenge berechnen': 'Calculate mass or amount of substance',
  'Frage {a} von {b} · Punkte: {c}': 'Question {a} of {b} · Points: {c}',
  '✅ Richtig!': '✅ Correct!', '❌ Leider falsch.': '❌ Unfortunately wrong.',
  'Weiter': 'Next', 'Ergebnis anzeigen': 'Show result', 'Fertig!': 'Done!',
  'Du hast {a} von {b} richtig beantwortet.': 'You answered {a} of {b} correctly.',
  'Nochmal üben': 'Practice again', 'Zurück zum Menü': 'Back to menu',
  'Es sind keine Elemente aktiviert.': 'No elements are activated.',
  'Aktiviere zuerst einige Elemente in der Konfiguration.': 'First activate some elements in the configuration.',
  '💡 Tipp anzeigen': '💡 Show hint', 'Tipp ausblenden': 'Hide hint',
  'Auto-Weiter nach Antwort': 'Auto-advance after answer',
  'Aus (nur per Knopf)': 'Off (button only)',
  '{a} Sekunden': '{a} seconds',
  'In welcher Gruppe steht dieses Element?': 'In which group is this element?',
  '{a} ({b}) steht in Gruppe {c}.': '{a} ({b}) is in group {c}.',
  'Wie lautet das Symbol von {a}?': 'What is the symbol of {a}?',
  'Wie heißt das Element mit dem Symbol {a}?': 'What is the element with symbol {a}?',
  '{a} hat das Symbol {b}.': '{a} has the symbol {b}.',
  '{a} steht für {b}.': '{a} stands for {b}.',
  'Wie lautet der lateinische Name von {a}?': 'What is the Latin name of {a}?',
  'Welches Element hat den lateinischen Namen {a}?': 'Which element has the Latin name {a}?',
  '{a} heißt auf Lateinisch {b}.': '{a} is {b} in Latin.',
  '{a} ist der lateinische Name von {b}.': '{a} is the Latin name of {b}.',
  'Welches Element fehlt in der Lücke?': 'Which element is missing in the gap?',
  'Welches Element steht zwischen den beiden?': 'Which element is between the two?',
  'Zwischen {a} und {b} steht {c} ({d}).': 'Between {a} and {b} is {c} ({d}).',
  'Welche Wertigkeit hat dieses Element?': 'What is the valence of this element?',
  '{a} hat die Wertigkeit {b}.': '{a} has valence {b}.',
  'Welche Elektronegativität hat dieses Element?': 'What is the electronegativity of this element?',
  '{a} hat die Elektronegativität {b}.': '{a} has electronegativity {b}.',
  'Welches Element hat die Elektronegativität {a}?': 'Which element has electronegativity {a}?',
  'Die Elektronegativität {a} gehört zu {b} ({c}).': 'Electronegativity {a} belongs to {b} ({c}).',
  'Wie lautet die Formel dieses Stoffes?': 'What is the formula of this substance?',
  'Wie heißt der Stoff mit dieser Formel?': 'What is the substance with this formula?',
  '{a} hat die Formel {b}.': '{a} has the formula {b}.',
  '{a} ist {b}.': '{a} is {b}.',
  'Wie groß ist die Molmasse dieses Elements?': 'What is the molar mass of this element?',
  'Die Molmasse von {a} ist {b} g/mol.': 'The molar mass of {a} is {b} g/mol.',
  'Welches Element hat diese Molmasse?': 'Which element has this molar mass?',
  '{a} g/mol ist die Molmasse von {b} ({c}).': '{a} g/mol is the molar mass of {b} ({c}).',
  'Berechne die Masse m von {a} mol {b} ({c}).': 'Calculate the mass m of {a} mol {b} ({c}).',
  'Berechne die Stoffmenge n von {a} g {b} ({c}).': 'Calculate the amount n of {a} g {b} ({c}).',
  'Gib einen Stoffnamen oder eine Formel ein.': 'Enter a substance name or a formula.',
  'z. B. Wasser oder H2O': 'e.g. water or H2O',
  'Kein Treffer – setze das Feld zurück und gib die Formel direkt ein.':
      'No match – reset the field and enter the formula directly.',
  'Molmasse berechnen': 'Calculate molar mass',
  '⚠️ Fehler': '⚠️ Error',
  'Molmasse': 'Molar mass',
  'Zusammensetzung': 'Composition',
  'Runde {a} von {b} · Punkte: {c}': 'Round {a} of {b} · Points: {c}',
  'Finde: {a}': 'Find: {a}',
  'Richtig!': 'Correct!', 'Falsch!': 'Wrong!', 'Zeit abgelaufen!': "Time's up!",
  'Gesucht war {a} ({b}).': 'The answer was {a} ({b}).',
  'Du hast {a} von {b} Elementen gefunden.': 'You found {a} of {b} elements.',
  'Zeit pro Element': 'Time per element',
  'Lateinisch: {a}': 'Latin: {a}',
  'Schalen: {a}': 'Shells: {a}',
  'Ordnungszahl': 'Atomic number', 'Gruppe': 'Group', 'Periode': 'Period',
  'Elektronegativität': 'Electronegativity', 'Dichte': 'Density',
  'Kategorie': 'Category', 'Schließen': 'Close',
  'Bitte eine Formel eingeben.': 'Please enter a formula.',
};

const Map<String, String> uiRu = {
  'Periodensystem Lernprogramm': 'Обучающая программа по таблице Менделеева',
  'Chemie lernen leicht gemacht!': 'Химия — это просто!',
  'Periodensystem': 'Таблица Менделеева',
  'Alle Elemente als Tabelle ansehen und nachschlagen': 'Просмотр всех элементов в виде таблицы',
  'Quiz & Üben': 'Викторина и тренировка',
  'Gruppe, Symbole, Lücken und lateinische Namen': 'Группы, символы, пробелы и латинские названия',
  'Molmasse-Rechner': 'Калькулятор молярной массы',
  'Molmasse einer chemischen Formel berechnen': 'Расчёт молярной массы химической формулы',
  'Fehler-Statistik': 'Статистика ошибок',
  'Problem-Elemente mit rotem Rahmen anzeigen': 'Показывать проблемные элементы красной рамкой',
  'Elemente konfigurieren': 'Настройка элементов',
  'Auswählen, welche Elemente abgefragt werden': 'Выбор элементов для опроса',
  'Sprache': 'Язык',
  'Einstellungen': 'Настройки',
  'Fehler-Statistik anzeigen': 'Показывать статистику ошибок',
  'Rote Rahmen zeigen Problem-Elemente': 'Красные рамки отмечают проблемные элементы',
  'Statistik zurücksetzen': 'Сбросить статистику',
  'Statistik wurde zurückgesetzt.': 'Статистика сброшена.',
  'Elemente mit Fehlern: {a} · Je dicker der rote Rahmen, desto mehr Probleme.':
      'Элементы с ошибками: {a} · Чем толще красная рамка, тем больше проблем.',
  'Tippe auf ein Element, um es ein- oder auszublenden.\nGraue Elemente werden nicht abgefragt.':
      'Нажмите на элемент, чтобы включить или скрыть его.\nСерые элементы не опрашиваются.',
  'Alle': 'Все', 'Keine': 'Ни одного', 'Wichtige Auswahl': 'Важный набор',
  'Aktiv: {a} von {b}': 'Активно: {a} из {b}',
  'Gruppe nennen': 'Назовите группу',
  'Zu einem Element die Gruppe (1–18) finden': 'Найдите группу (1–18) элемента',
  'Symbol → Name': 'Символ → название',
  'Zum Symbol den richtigen Namen finden': 'Найдите название по символу',
  'Name → Symbol': 'Название → символ',
  'Zum Namen die richtige Abkürzung finden': 'Найдите символ по названию',
  'Lateinische Namen': 'Латинские названия',
  'Deutsche und lateinische Namen zuordnen': 'Сопоставьте названия с латинскими',
  'Lücke füllen': 'Заполните пробел',
  'Das fehlende Element zwischen Nachbarn finden': 'Найдите недостающий элемент между соседями',
  'Wertigkeit': 'Валентность',
  'Die Wertigkeit eines Elements nennen': 'Назовите валентность элемента',
  'Element → Elektronegativität': 'Элемент → электроотрицательность',
  'Die EN eines Elements nennen': 'Назовите ЭО элемента',
  'Elektronegativität → Element': 'Электроотрицательность → элемент',
  'Zum EN-Wert das Element finden': 'Найдите элемент по значению ЭО',
  'Element finden': 'Найди элемент',
  'Gesuchtes Element in der Tabelle anklicken (Zeit läuft!)': 'Нажмите нужный элемент в таблице (время идёт!)',
  'Stoff → Formel': 'Вещество → формула',
  'Zur Stoffbezeichnung die Formel finden': 'Найдите формулу по названию вещества',
  'Formel → Stoff': 'Формула → вещество',
  'Zur Formel den Stoffnamen finden': 'Найдите название вещества по формуле',
  'Element → Molmasse': 'Элемент → молярная масса',
  'Die Molmasse eines Elements nennen': 'Назовите молярную массу элемента',
  'Molmasse → Element': 'Молярная масса → элемент',
  'Zur Molmasse das Element finden': 'Найдите элемент по молярной массе',
  'Stoffmenge (n, m, M)': 'Количество вещества (n, m, M)',
  'Masse oder Stoffmenge berechnen': 'Рассчитайте массу или количество вещества',
  'Frage {a} von {b} · Punkte: {c}': 'Вопрос {a} из {b} · Очки: {c}',
  '✅ Richtig!': '✅ Верно!', '❌ Leider falsch.': '❌ К сожалению, неверно.',
  'Weiter': 'Далее', 'Ergebnis anzeigen': 'Показать результат', 'Fertig!': 'Готово!',
  'Du hast {a} von {b} richtig beantwortet.': 'Вы правильно ответили на {a} из {b}.',
  'Nochmal üben': 'Тренироваться снова', 'Zurück zum Menü': 'Назад в меню',
  'Es sind keine Elemente aktiviert.': 'Ни один элемент не активирован.',
  'Aktiviere zuerst einige Elemente in der Konfiguration.': 'Сначала активируйте элементы в настройках.',
  '💡 Tipp anzeigen': '💡 Показать подсказку', 'Tipp ausblenden': 'Скрыть подсказку',
  'Auto-Weiter nach Antwort': 'Автопереход после ответа',
  'Aus (nur per Knopf)': 'Выкл (только кнопкой)',
  '{a} Sekunden': '{a} секунд',
  'In welcher Gruppe steht dieses Element?': 'В какой группе находится этот элемент?',
  '{a} ({b}) steht in Gruppe {c}.': '{a} ({b}) находится в группе {c}.',
  'Wie lautet das Symbol von {a}?': 'Какой символ у {a}?',
  'Wie heißt das Element mit dem Symbol {a}?': 'Как называется элемент с символом {a}?',
  '{a} hat das Symbol {b}.': '{a} имеет символ {b}.',
  '{a} steht für {b}.': '{a} означает {b}.',
  'Wie lautet der lateinische Name von {a}?': 'Какое латинское название у {a}?',
  'Welches Element hat den lateinischen Namen {a}?': 'У какого элемента латинское название {a}?',
  '{a} heißt auf Lateinisch {b}.': '{a} по-латыни — {b}.',
  '{a} ist der lateinische Name von {b}.': '{a} — латинское название элемента {b}.',
  'Welches Element fehlt in der Lücke?': 'Какого элемента не хватает в пробеле?',
  'Welches Element steht zwischen den beiden?': 'Какой элемент находится между ними?',
  'Zwischen {a} und {b} steht {c} ({d}).': 'Между {a} и {b} находится {c} ({d}).',
  'Welche Wertigkeit hat dieses Element?': 'Какая валентность у этого элемента?',
  '{a} hat die Wertigkeit {b}.': '{a} имеет валентность {b}.',
  'Welche Elektronegativität hat dieses Element?': 'Какая электроотрицательность у этого элемента?',
  '{a} hat die Elektronegativität {b}.': '{a} имеет электроотрицательность {b}.',
  'Welches Element hat die Elektronegativität {a}?': 'У какого элемента электроотрицательность {a}?',
  'Die Elektronegativität {a} gehört zu {b} ({c}).': 'Электроотрицательность {a} у элемента {b} ({c}).',
  'Wie lautet die Formel dieses Stoffes?': 'Какая формула у этого вещества?',
  'Wie heißt der Stoff mit dieser Formel?': 'Как называется вещество с этой формулой?',
  '{a} hat die Formel {b}.': '{a} имеет формулу {b}.',
  '{a} ist {b}.': '{a} — это {b}.',
  'Wie groß ist die Molmasse dieses Elements?': 'Какова молярная масса этого элемента?',
  'Die Molmasse von {a} ist {b} g/mol.': 'Молярная масса {a} — {b} г/моль.',
  'Welches Element hat diese Molmasse?': 'У какого элемента такая молярная масса?',
  '{a} g/mol ist die Molmasse von {b} ({c}).': '{a} г/моль — молярная масса {b} ({c}).',
  'Berechne die Masse m von {a} mol {b} ({c}).': 'Рассчитайте массу m для {a} моль {b} ({c}).',
  'Berechne die Stoffmenge n von {a} g {b} ({c}).': 'Рассчитайте количество вещества n для {a} г {b} ({c}).',
  'Gib einen Stoffnamen oder eine Formel ein.': 'Введите название вещества или формулу.',
  'z. B. Wasser oder H2O': 'напр. вода или H2O',
  'Kein Treffer – setze das Feld zurück und gib die Formel direkt ein.':
      'Ничего не найдено — очистите поле и введите формулу напрямую.',
  'Molmasse berechnen': 'Рассчитать молярную массу',
  '⚠️ Fehler': '⚠️ Ошибка',
  'Molmasse': 'Молярная масса',
  'Zusammensetzung': 'Состав',
  'Runde {a} von {b} · Punkte: {c}': 'Раунд {a} из {b} · Очки: {c}',
  'Finde: {a}': 'Найди: {a}',
  'Richtig!': 'Верно!', 'Falsch!': 'Неверно!', 'Zeit abgelaufen!': 'Время вышло!',
  'Gesucht war {a} ({b}).': 'Искали {a} ({b}).',
  'Du hast {a} von {b} Elementen gefunden.': 'Вы нашли {a} из {b} элементов.',
  'Zeit pro Element': 'Время на элемент',
  'Lateinisch: {a}': 'Латынь: {a}',
  'Schalen: {a}': 'Оболочки: {a}',
  'Ordnungszahl': 'Атомный номер', 'Gruppe': 'Группа', 'Periode': 'Период',
  'Elektronegativität': 'Электроотрицательность', 'Dichte': 'Плотность',
  'Kategorie': 'Категория', 'Schließen': 'Закрыть',
  'Bitte eine Formel eingeben.': 'Пожалуйста, введите формулу.',
};
