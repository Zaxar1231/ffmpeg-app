// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Kadra';

  @override
  String get navHome => 'Главная';

  @override
  String get navTools => 'Инструменты';

  @override
  String get navDownloads => 'Загрузки';

  @override
  String get navQueue => 'Очередь';

  @override
  String get navPresets => 'Пресеты';

  @override
  String get navComponents => 'Компоненты';

  @override
  String get navSettings => 'Настройки';

  @override
  String get cancel => 'Отмена';

  @override
  String get close => 'Закрыть';

  @override
  String get copy => 'Копировать';

  @override
  String get copied => 'Скопировано';

  @override
  String get choose => 'Выбрать';

  @override
  String get search => 'Поиск';

  @override
  String get more => 'Ещё';

  @override
  String get auto => 'авто';

  @override
  String get notSet => 'Не задано';

  @override
  String get nothingFound => 'Ничего не найдено';

  @override
  String get helpTooltip => 'Подробнее';

  @override
  String get resetTooltip => 'Сбросить';

  @override
  String get resetSection => 'Сбросить раздел';

  @override
  String get resetAll => 'Сбросить все настройки';

  @override
  String get install => 'Установить';

  @override
  String get update => 'Обновить';

  @override
  String get reinstall => 'Переустановить';

  @override
  String get rollback => 'Откатить';

  @override
  String get remove => 'Удалить';

  @override
  String get activate => 'Сделать активной';

  @override
  String get reload => 'Перечитать файл';

  @override
  String get pause => 'Пауза';

  @override
  String get resume => 'Продолжить';

  @override
  String get retry => 'Повторить';

  @override
  String get openFolder => 'Открыть папку';

  @override
  String get showLog => 'Показать лог';

  @override
  String get showCommand => 'Показать команду';

  @override
  String get removeFromList => 'Убрать из списка';

  @override
  String get logTitle => 'Полный лог';

  @override
  String get commandTitle => 'Команда';

  @override
  String get unitB => 'Б';

  @override
  String get unitKB => 'КБ';

  @override
  String get unitMB => 'МБ';

  @override
  String get unitGB => 'ГБ';

  @override
  String get unitTB => 'ТБ';

  @override
  String get unitKbps => 'кбит/с';

  @override
  String get unitMbps => 'Мбит/с';

  @override
  String get unitFps => 'к/с';

  @override
  String get unitHz => 'Гц';

  @override
  String get unitSecond => 'с';

  @override
  String get homeTitle => 'Главная';

  @override
  String get openFile => 'Открыть файл';

  @override
  String get closeFile => 'Закрыть файл';

  @override
  String get dropTitle => 'Перетащите файл сюда';

  @override
  String get dropSubtitle => 'или нажмите, чтобы выбрать: видео, аудио, картинка';

  @override
  String get shortcutOpenHint => 'Ctrl+O — открыть файл, Ctrl+1…7 — разделы';

  @override
  String get probeFailed => 'Не удалось прочитать файл';

  @override
  String get openAnother => 'Открыть другой';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get ffmpegMissingTitle => 'ffmpeg не найден';

  @override
  String get ffmpegMissingBody =>
      'Без него приложение не может работать с файлами. Установите ffmpeg в разделе «Компоненты» — это займёт минуту.';

  @override
  String get openComponents => 'Открыть «Компоненты»';

  @override
  String get addedToQueue => 'Задача добавлена в очередь';

  @override
  String get openQueue => 'Открыть очередь';

  @override
  String get infoContainer => 'Контейнер';

  @override
  String get infoFormat => 'Формат';

  @override
  String get infoDuration => 'Длительность';

  @override
  String get infoSize => 'Размер';

  @override
  String get infoBitrate => 'Битрейт';

  @override
  String get infoStartTime => 'Начало';

  @override
  String get infoStreams => 'Потоков';

  @override
  String infoChapters(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count главы',
      many: '$count глав',
      few: '$count главы',
      one: '$count глава',
    );
    return '$_temp0';
  }

  @override
  String get infoTags => 'Теги';

  @override
  String get infoCodec => 'Кодек';

  @override
  String get infoResolution => 'Разрешение';

  @override
  String get infoFrameRate => 'Частота кадров';

  @override
  String get infoPixelFormat => 'Пиксельный формат';

  @override
  String infoBits(int bits) {
    return '$bits бит';
  }

  @override
  String get infoColor => 'Цвет';

  @override
  String get infoFieldOrder => 'Развёртка';

  @override
  String get infoRotation => 'Поворот';

  @override
  String get infoMastering => 'Мастеринг HDR';

  @override
  String get infoContentLight => 'Уровни яркости';

  @override
  String get infoSampleRate => 'Частота дискретизации';

  @override
  String get infoChannels => 'Каналы';

  @override
  String get infoSampleFormat => 'Формат сэмплов';

  @override
  String get infoFrames => 'Кадров';

  @override
  String get infoVersion => 'Версия';

  @override
  String get streamVideo => 'Видео';

  @override
  String get streamAudio => 'Аудио';

  @override
  String get streamSubtitle => 'Субтитры';

  @override
  String get streamCover => 'Обложка';

  @override
  String get streamAttachment => 'Вложение';

  @override
  String get streamData => 'Данные';

  @override
  String get dispositionDefault => 'по умолчанию';

  @override
  String get dispositionForced => 'принудительные';

  @override
  String get toolsSearchHint => 'Найти инструмент: «сжать», «gif», «субтитры»…';

  @override
  String toolComingSoon(int stage) {
    return 'Появится на этапе $stage разработки';
  }

  @override
  String stageLabel(int stage) {
    return 'этап $stage';
  }

  @override
  String get losslessTag => 'мгновенно, без потери качества';

  @override
  String get needsOtherBuild => 'нужна другая сборка';

  @override
  String needsBuildTooltip(String names) {
    return 'В установленной сборке ffmpeg нет: $names. Установите full-сборку в «Компонентах».';
  }

  @override
  String get catAnalysis => 'Анализ и информация';

  @override
  String get catConvert => 'Конвертация и сжатие';

  @override
  String get catEdit => 'Монтаж и редактирование';

  @override
  String get catAudio => 'Аудио';

  @override
  String get catSubtitles => 'Субтитры';

  @override
  String get catImages => 'Изображения и анимация';

  @override
  String get catMetadata => 'Метаданные и главы';

  @override
  String get catCapture => 'Запись и стриминг';

  @override
  String get catRepair => 'Ремонт файлов';

  @override
  String get catDownload => 'Загрузка видео';

  @override
  String get catAutomation => 'Пакетная обработка';

  @override
  String get catExpert => 'Режим эксперта';

  @override
  String get toolMediaInfo => 'Информация о файле';

  @override
  String get toolMediaInfoDesc => 'Контейнер, потоки, кодеки, битрейт, HDR, главы и теги.';

  @override
  String get toolIntegrity => 'Проверка целостности';

  @override
  String get toolIntegrityDesc => 'Декодирует файл целиком и перечисляет все найденные ошибки.';

  @override
  String get toolLoudness => 'Замер громкости';

  @override
  String get toolLoudnessDesc => 'LUFS, True Peak и LRA по стандарту EBU R128.';

  @override
  String get toolWaveform => 'Осциллограмма и спектр';

  @override
  String get toolWaveformDesc => 'Картинка с формой волны или спектрограммой звука.';

  @override
  String get toolDetect => 'Детекторы';

  @override
  String get toolDetectDesc => 'Тишина, чёрные и замершие кадры, смена сцен, чёрные поля.';

  @override
  String get toolCompareQuality => 'Сравнение качества';

  @override
  String get toolCompareQualityDesc => 'VMAF, PSNR и SSIM между оригиналом и результатом.';

  @override
  String get toolConvert => 'Конвертация';

  @override
  String get toolConvertDesc => 'Любой контейнер и кодек: MP4, MKV, WebM, MP3, FLAC и другие.';

  @override
  String get toolCompress => 'Сжатие';

  @override
  String get toolCompressDesc => 'Уменьшить размер: по качеству или до заданного размера файла.';

  @override
  String get toolHdrToSdr => 'HDR → SDR';

  @override
  String get toolHdrToSdrDesc => 'Тонмаппинг HDR-видео для обычных экранов.';

  @override
  String get toolTrim => 'Обрезка';

  @override
  String get toolTrimDesc => 'Быстро по ключевым кадрам или точно до кадра.';

  @override
  String get toolCutJoin => 'Вырезать фрагменты';

  @override
  String get toolCutJoinDesc => 'Удалить лишние куски или оставить только нужные.';

  @override
  String get toolConcat => 'Склейка';

  @override
  String get toolConcatDesc => 'Соединить несколько файлов в один.';

  @override
  String get toolSplit => 'Разделение';

  @override
  String get toolSplitDesc => 'По времени, размеру, главам, тишине или сценам.';

  @override
  String get toolCropScale => 'Кадр и размер';

  @override
  String get toolCropScaleDesc => 'Кадрирование, масштаб, поворот, вертикальное видео.';

  @override
  String get toolSpeed => 'Скорость и FPS';

  @override
  String get toolSpeedDesc => 'Ускорение, замедление, реверс, интерполяция кадров.';

  @override
  String get toolRestore => 'Улучшение видео';

  @override
  String get toolRestoreDesc => 'Деинтерлейс, стабилизация, шумоподавление, резкость.';

  @override
  String get toolColor => 'Цвет';

  @override
  String get toolColorDesc => 'Яркость, контраст, кривые, 3D LUT, ч/б и сепия.';

  @override
  String get toolOverlay => 'Водяной знак и текст';

  @override
  String get toolOverlayDesc => 'Картинка, текст или таймкод поверх видео.';

  @override
  String get toolBlur => 'Размытие и логотипы';

  @override
  String get toolBlurDesc => 'Размыть или пикселизовать область, убрать логотип.';

  @override
  String get toolStack => 'Картинка в картинке';

  @override
  String get toolStackDesc => 'PiP, сетка, сравнение бок о бок.';

  @override
  String get toolTransitions => 'Затухания и переходы';

  @override
  String get toolTransitionsDesc => 'Fade in/out и все виды переходов xfade.';

  @override
  String get toolLoop => 'Кольцевание';

  @override
  String get toolLoopDesc => 'Повтор видео и бумеранг.';

  @override
  String get toolExtractAudio => 'Извлечь звук';

  @override
  String get toolExtractAudioDesc => 'Сохранить звуковую дорожку отдельным файлом.';

  @override
  String get toolReplaceAudio => 'Дорожки звука';

  @override
  String get toolReplaceAudioDesc => 'Заменить, добавить, удалить дорожку или выбрать основную.';

  @override
  String get toolNormalize => 'Нормализация громкости';

  @override
  String get toolNormalizeDesc => 'Двухпроходная loudnorm: YouTube −14, подкаст −16, ТВ −23 LUFS.';

  @override
  String get toolDenoise => 'Шумоподавление';

  @override
  String get toolDenoiseDesc => 'afftdn, anlmdn, RNNoise, удаление щелчков и клиппинга.';

  @override
  String get toolAudioFx => 'Обработка звука';

  @override
  String get toolAudioFxDesc => 'Эквалайзер, компрессор, лимитер, темп и тон, каналы.';

  @override
  String get toolMix => 'Смешивание';

  @override
  String get toolMixDesc => 'Несколько дорожек вместе, автоприглушение музыки под голос.';

  @override
  String get toolTranscribe => 'Транскрипция';

  @override
  String get toolTranscribeDesc => 'Распознать речь в субтитры через whisper.';

  @override
  String get toolBurnSubs => 'Вшить субтитры';

  @override
  String get toolBurnSubsDesc => 'Субтитры прямо в картинке, со стилями.';

  @override
  String get toolSoftSubs => 'Дорожки субтитров';

  @override
  String get toolSoftSubsDesc => 'Добавить, извлечь или удалить отдельную дорожку.';

  @override
  String get toolConvertSubs => 'Конвертация субтитров';

  @override
  String get toolConvertSubsDesc => 'SRT ↔ ASS ↔ VTT, сдвиг таймингов, кодировка.';

  @override
  String get toolGif => 'GIF и анимации';

  @override
  String get toolGifDesc => 'Качественный GIF с палитрой, анимированные WebP и APNG.';

  @override
  String get toolFrames => 'Извлечь кадры';

  @override
  String get toolFramesDesc => 'Каждый N-й кадр, по сценам или в заданное время.';

  @override
  String get toolContactSheet => 'Раскадровка';

  @override
  String get toolContactSheetDesc => 'Сетка миниатюр из видео.';

  @override
  String get toolSlideshow => 'Слайд-шоу';

  @override
  String get toolSlideshowDesc => 'Видео из картинок с переходами.';

  @override
  String get toolAudioToVideo => 'Картинка + звук';

  @override
  String get toolAudioToVideoDesc => 'Видео из обложки и аудио, например для YouTube.';

  @override
  String get toolVisualizer => 'Визуализатор звука';

  @override
  String get toolVisualizerDesc => 'Волна, спектр или вектороскоп в видео.';

  @override
  String get toolImageConvert => 'Конвертация картинок';

  @override
  String get toolImageConvertDesc => 'JPEG, PNG, WebP, AVIF: сжатие и смена формата.';

  @override
  String get toolTags => 'Теги';

  @override
  String get toolTagsDesc => 'Название, исполнитель, альбом, год и прочее.';

  @override
  String get toolCover => 'Обложка';

  @override
  String get toolCoverDesc => 'Добавить, заменить или извлечь обложку.';

  @override
  String get toolChapters => 'Главы';

  @override
  String get toolChaptersDesc => 'Добавить, переименовать, импорт и экспорт глав.';

  @override
  String get toolScreenRecord => 'Запись экрана';

  @override
  String get toolScreenRecordDesc => 'Весь экран, область или окно.';

  @override
  String get toolWebcam => 'Камера и микрофон';

  @override
  String get toolWebcamDesc => 'Запись с веб-камеры и микрофона.';

  @override
  String get toolStream => 'Стрим';

  @override
  String get toolStreamDesc => 'RTMP / SRT на YouTube, Twitch или свой сервер.';

  @override
  String get toolHls => 'HLS / DASH';

  @override
  String get toolHlsDesc => 'Упаковка для воспроизведения в браузере.';

  @override
  String get toolRepair => 'Ремонт';

  @override
  String get toolRepairDesc => 'Ремукс битых файлов, таймстемпы, рассинхрон.';

  @override
  String get toolFaststart => 'Faststart для MP4';

  @override
  String get toolFaststartDesc => 'Быстрый старт видео в браузере.';

  @override
  String get toolDownload => 'Загрузка по ссылке';

  @override
  String get toolDownloadDesc => 'Видео и аудио с сайтов через yt-dlp.';

  @override
  String get toolBatch => 'Пакетная обработка';

  @override
  String get toolBatchDesc => 'Одна операция для папки или набора файлов.';

  @override
  String get toolRecipes => 'Рецепты';

  @override
  String get toolRecipesDesc => 'Цепочки операций: обрезать → нормализовать → сжать.';

  @override
  String get toolWatchFolder => 'Наблюдение за папкой';

  @override
  String get toolWatchFolderDesc => 'Новые файлы обрабатываются автоматически.';

  @override
  String get toolCommandEditor => 'Редактор команд';

  @override
  String get toolCommandEditorDesc => 'Своя команда ffmpeg с автодополнением.';

  @override
  String get toolFilterGraph => 'Конструктор фильтров';

  @override
  String get toolFilterGraphDesc => 'Цепочка фильтров списком с параметрами.';

  @override
  String get toolCommandLog => 'Журнал команд';

  @override
  String get toolCommandLogDesc => 'Все запущенные команды с логами.';

  @override
  String get queueEmptyTitle => 'Очередь пуста';

  @override
  String get queueEmptyBody => 'Задачи из инструментов появятся здесь с прогрессом, скоростью и оставшимся временем.';

  @override
  String get queueActive => 'В работе и в очереди';

  @override
  String get queueHistory => 'История';

  @override
  String get clearFinished => 'Очистить завершённые';

  @override
  String parallelJobsShort(int count) {
    return 'Параллельно: $count';
  }

  @override
  String get statusQueued => 'В очереди';

  @override
  String get statusRunning => 'Выполняется';

  @override
  String get statusPaused => 'Пауза';

  @override
  String get statusCompleted => 'Готово';

  @override
  String statusCompletedWithFindings(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Найдено $count проблемы',
      many: 'Найдено $count проблем',
      few: 'Найдено $count проблемы',
      one: 'Найдена $count проблема',
    );
    return '$_temp0';
  }

  @override
  String get statusNoProblems => 'Ошибок не найдено';

  @override
  String get statusFailed => 'Ошибка';

  @override
  String get statusCanceled => 'Отменено';

  @override
  String etaLabel(String time) {
    return 'осталось $time';
  }

  @override
  String tookLabel(String time) {
    return 'заняло $time';
  }

  @override
  String attemptsLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count попытки',
      many: '$count попыток',
      few: '$count попытки',
      one: '$count попытка',
    );
    return '$_temp0';
  }

  @override
  String get priorityHigh => 'Высокий приоритет';

  @override
  String get priorityRaise => 'Поднять приоритет';

  @override
  String get priorityNormal => 'Обычный приоритет';

  @override
  String get errToolMissing => 'Не найден нужный инструмент. Установите его в разделе «Компоненты».';

  @override
  String errFileNotFound(String path) {
    return 'Файл не найден: $path';
  }

  @override
  String errPermissionDenied(String path) {
    return 'Нет доступа к файлу или папке: $path. Выберите другую папку для сохранения.';
  }

  @override
  String get errDiskFull => 'Закончилось место на диске.';

  @override
  String get errInvalidData =>
      'Файл повреждён или его формат не поддерживается. Попробуйте «Ремонт» или «Проверку целостности».';

  @override
  String errEncoderMissing(String name) {
    return 'В этой сборке ffmpeg нет кодировщика «$name». Выберите другой кодек или установите full-сборку.';
  }

  @override
  String errDecoderMissing(String name) {
    return 'В этой сборке ffmpeg нет декодера «$name».';
  }

  @override
  String errFilterMissing(String name) {
    return 'В этой сборке ffmpeg нет фильтра «$name». Установите full-сборку в «Компонентах».';
  }

  @override
  String get errCodecContainer => 'Кодек не поддерживается этим контейнером. Попробуйте MKV — он принимает почти всё.';

  @override
  String get errOddDimensions => 'Ширина и высота должны быть чётными для этого кодека. Включите округление размера.';

  @override
  String get errHwUnavailable =>
      'Аппаратный кодировщик недоступен (нет видеокарты или драйвера). Отключите ускорение или выберите программный кодек.';

  @override
  String errInvalidArgument(String arg) {
    return 'Неверный параметр: $arg';
  }

  @override
  String get errStreamNotFound => 'В файле нет выбранной дорожки.';

  @override
  String get errSameAsInput => 'Результат нельзя записать поверх исходного файла. Выберите другое имя.';

  @override
  String get errNetwork => 'Проблема с сетью. Проверьте подключение и попробуйте снова.';

  @override
  String get errUnsupportedUrl => 'Этот сайт или ссылка не поддерживаются.';

  @override
  String get errLoginRequired => 'Нужен вход в аккаунт. Включите cookies из браузера в настройках загрузок.';

  @override
  String get errVideoUnavailable => 'Видео недоступно: удалено, приватное или заблокировано в регионе.';

  @override
  String get errLoudnessMeasure => 'Не удалось измерить громкость: в файле тишина или нет звука.';

  @override
  String get errCanceled => 'Отменено.';

  @override
  String get errUnknown => 'Не получилось. Подробности в полном логе.';

  @override
  String get checkUpdates => 'Проверить обновления';

  @override
  String lastChecked(String time) {
    return 'Проверено в $time';
  }

  @override
  String get compFfmpeg => 'ffmpeg и ffprobe';

  @override
  String get compFfmpegDesc => 'Основной движок: конвертация, фильтры, анализ. Обязателен.';

  @override
  String get compYtdlp => 'yt-dlp';

  @override
  String get compYtdlpDesc => 'Загрузка видео и аудио с YouTube и тысяч других сайтов.';

  @override
  String get compDeno => 'Deno';

  @override
  String get compDenoDesc => 'JavaScript-рантайм, который нужен yt-dlp для YouTube.';

  @override
  String get compAria2 => 'aria2c';

  @override
  String get compAria2Desc => 'Ускоренная многопоточная загрузка для yt-dlp.';

  @override
  String get originCustom => 'свой путь';

  @override
  String get originManaged => 'установлен приложением';

  @override
  String get originSystem => 'системный';

  @override
  String get originNone => 'не найден';

  @override
  String get updateAvailable => 'есть обновление';

  @override
  String get inUse => 'Используется';

  @override
  String get installedVersion => 'Версия';

  @override
  String get sourceLabel => 'Источник';

  @override
  String get latestAvailable => 'Доступно';

  @override
  String get noChecksum => 'издатель не публикует SHA-256';

  @override
  String removeComponentConfirm(String name) {
    return 'Удалить «$name» и все сохранённые версии?';
  }

  @override
  String componentError(String error) {
    return 'Ошибка: $error';
  }

  @override
  String versionHistory(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Установленные версии ($count)',
      one: 'Установленные версии ($count)',
    );
    return '$_temp0';
  }

  @override
  String get phaseResolving => 'Поиск последней версии…';

  @override
  String get phaseDownloading => 'Скачивание';

  @override
  String get phaseVerifying => 'Проверка SHA-256…';

  @override
  String get phaseExtracting => 'Распаковка…';

  @override
  String get phaseTesting => 'Проверка запуска…';

  @override
  String get flavorFull => 'full';

  @override
  String get flavorEssentials => 'essentials';

  @override
  String get channelRelease => 'релиз';

  @override
  String get channelNightly => 'nightly';

  @override
  String get channelStable => 'stable';

  @override
  String get btbnHint => 'Статические сборки BtbN. GPL — всё, включая x264/x265; LGPL — без GPL-кодеков.';

  @override
  String get gyanHint => 'Сборки gyan.dev для Windows. full — максимум фильтров и кодеков (whisper, vmaf, frei0r).';

  @override
  String get customPathNone => 'Можно указать свой бинарник вместо загруженного.';

  @override
  String customPathValue(String path) {
    return 'Используется свой путь: $path';
  }

  @override
  String get useCustomBinary => 'Указать свой';

  @override
  String installViaPackageManager(String pkg) {
    return 'Установите пакет «$pkg» через менеджер пакетов системы.';
  }

  @override
  String get buildInfoTitle => 'Возможности сборки ffmpeg';

  @override
  String get licenseLabel => 'Лицензия';

  @override
  String get encoders => 'Кодировщики';

  @override
  String get decoders => 'Декодеры';

  @override
  String get filters => 'Фильтры';

  @override
  String get muxers => 'Контейнеры';

  @override
  String get configuration => 'Конфигурация';

  @override
  String get hwTitle => 'Аппаратное ускорение';

  @override
  String get redetect => 'Перепроверить';

  @override
  String get hwDetecting => 'Пробное кодирование на каждом ускорителе…';

  @override
  String get hwDecode => 'Декодирование';

  @override
  String get hwBestDecode => 'Лучшее для декодирования';

  @override
  String get hwEncoders => 'Рабочие кодировщики';

  @override
  String get hwSoftwareOnly => 'только программно';

  @override
  String get hwNoneWorking => 'не найдено, кодирование будет на процессоре';

  @override
  String hwFailed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не прошли проверку: $count',
      one: 'Не прошёл проверку: $count',
    );
    return '$_temp0';
  }

  @override
  String get plannedComponents => 'Скоро';

  @override
  String get compRnnoise => 'Модели RNNoise (шумоподавление голоса)';

  @override
  String get compVmaf => 'Модели VMAF (оценка качества)';

  @override
  String get compWhisper => 'Модели whisper.cpp (транскрипция)';

  @override
  String get compFrei0r => 'frei0r и LADSPA/LV2 плагины';

  @override
  String get compLuts => '3D LUT-пакеты (.cube)';

  @override
  String get compFonts => 'Шрифты для субтитров и текста';

  @override
  String get downloadsSoonTitle => 'Загрузка по ссылкам — на этапе 2';

  @override
  String downloadsReady(String path) {
    return 'yt-dlp готов: $path';
  }

  @override
  String get downloadsNeedYtdlp => 'Для загрузки понадобится yt-dlp. Его можно установить уже сейчас.';

  @override
  String get presetsSoonTitle => 'Пресеты появятся вместе с конвертацией';

  @override
  String get presetsSoonBody =>
      '«Для Telegram», «Для YouTube», «Для Discord (до 10 МБ)», «Для монтажа», «Архив без потерь» и свои пресеты с экспортом в JSON.';

  @override
  String get settingsSearchHint => 'Поиск по настройкам';

  @override
  String showAdvanced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Показать ещё $count расширенной настройки',
      many: 'Показать ещё $count расширенных настроек',
      few: 'Показать ещё $count расширенные настройки',
      one: 'Показать ещё $count расширенную настройку',
    );
    return '$_temp0';
  }

  @override
  String get secGeneral => 'Общие';

  @override
  String get secAppearance => 'Внешний вид';

  @override
  String get secPerformance => 'Производительность';

  @override
  String get secPaths => 'Пути и папки';

  @override
  String get secDownloads => 'Загрузки (yt-dlp)';

  @override
  String get secUpdates => 'Компоненты и обновления';

  @override
  String get secNotifications => 'Уведомления';

  @override
  String get secExpert => 'Для экспертов';

  @override
  String get setLanguage => 'Язык интерфейса';

  @override
  String get setLanguageHint => 'По умолчанию — как в системе';

  @override
  String get languageSystem => 'Как в системе';

  @override
  String get setAdvancedMode => 'Расширенный режим';

  @override
  String get setAdvancedModeHint => 'Показывать все параметры, а не только главные';

  @override
  String get setAdvancedModeHelp =>
      'В простом режиме у инструментов и в настройках видны только параметры, которые нужны в 90% случаев; остальные берут разумные значения по умолчанию. Расширенный режим открывает всё: профили и уровни кодеков, пиксельные форматы, число потоков и т. п. Поиск находит расширенные настройки в любом режиме. По умолчанию: выключен.';

  @override
  String get setTheme => 'Тема';

  @override
  String get setThemeHint => 'Светлая, тёмная или как в системе';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get setAccent => 'Акцентный цвет';

  @override
  String get setAccentHint => 'Цвет кнопок и выделений';

  @override
  String get setAccentHelp =>
      '«Системный» берёт акцент из настроек Windows или GNOME/KDE (Material You). Если система цвет не сообщает, используется выбранный ниже. По умолчанию: системный.';

  @override
  String get accentSystem => 'Системный';

  @override
  String get accentCustom => 'Свой';

  @override
  String get setParallel => 'Параллельные задачи';

  @override
  String get setParallelHint => 'Сколько задач очереди выполнять одновременно';

  @override
  String get setParallelHelp =>
      'ffmpeg и так использует все ядра процессора, поэтому для перекодирования обычно лучше 1–2 задачи: каждая закончится быстрее. Больше задач выгодно для лёгких операций (ремукс, обрезка без перекодирования, загрузки) и при аппаратном кодировании, где видеокарта может вести несколько потоков. Рекомендуется: 1–2. По умолчанию: 1.';

  @override
  String get zoneFasterEach => 'каждая быстрее';

  @override
  String get zoneMoreAtOnce => 'больше сразу';

  @override
  String get setHwAccel => 'Аппаратное ускорение';

  @override
  String get setHwAccelHint => 'Кодировать на видеокарте, если она найдена';

  @override
  String get setHwAccelHelp =>
      'NVENC (NVIDIA), Quick Sync (Intel), AMF (AMD), VAAPI и Vulkan кодируют в разы быстрее процессора, но при том же размере файла качество немного ниже. Для архива и максимального качества выключите. Что именно найдено, видно в «Компонентах». По умолчанию: включено.';

  @override
  String get setRetries => 'Повторы при ошибке';

  @override
  String get setRetriesHint => 'Сколько раз перезапускать упавшую задачу';

  @override
  String get setRetriesHelp =>
      'Полезно для загрузок и сетевых источников, где сбои бывают временными. Для локальных файлов ошибка обычно повторяется, поэтому по умолчанию: 0.';

  @override
  String get setThreads => 'Потоки ffmpeg';

  @override
  String get setThreadsHint => 'Ограничить число потоков процессора на задачу';

  @override
  String get setThreadsHelp =>
      '«авто» позволяет ffmpeg самому выбрать оптимум. Ограничение нужно, если вы хотите оставить процессор свободным для других программ во время кодирования. По умолчанию: авто.';

  @override
  String get setOutputDir => 'Папка для результатов';

  @override
  String get setOutputDirHint => 'Куда сохранять готовые файлы';

  @override
  String get setOutputDirHelp =>
      'Если не задана, результаты сохраняются в папку «Kadra» внутри «Видео» (или домашней папки). Каждый инструмент также позволяет выбрать место вручную.';

  @override
  String outputDirDefault(String path) {
    return 'По умолчанию: $path';
  }

  @override
  String get setCustomFfmpeg => 'Свой ffmpeg';

  @override
  String get setCustomFfmpegHint => 'Путь к уже установленному ffmpeg';

  @override
  String get setCustomFfmpegHelp =>
      'Имеет приоритет над загруженным компонентом и системным PATH. ffprobe ищется рядом автоматически. Полезно, если у вас своя сборка с нестандартными библиотеками.';

  @override
  String get setCustomFfprobe => 'Свой ffprobe';

  @override
  String get setCustomFfprobeHint => 'Если он лежит не рядом с ffmpeg';

  @override
  String get setCustomYtdlp => 'Свой yt-dlp';

  @override
  String get setCustomYtdlpHint => 'Путь к уже установленному yt-dlp';

  @override
  String get setFragments => 'Параллельные фрагменты';

  @override
  String get setFragmentsHint => 'Сколько частей видео качать одновременно';

  @override
  String get setFragmentsHelp =>
      'yt-dlp --concurrent-fragments. Ускоряет загрузку потоковых форматов (DASH/HLS) с YouTube и других сайтов. Слишком большое значение может привести к временной блокировке со стороны сайта. Рекомендуется: 4–8. По умолчанию: 4.';

  @override
  String get zoneGentle => 'бережнее к сайту';

  @override
  String get zoneFaster => 'быстрее';

  @override
  String get setPolicyFfmpeg => 'Обновления ffmpeg';

  @override
  String get setPolicyHint => 'Что делать, когда вышла новая версия';

  @override
  String get setPolicyYtdlp => 'Обновления yt-dlp';

  @override
  String get setPolicyYtdlpHint => 'Сайты часто меняются — лучше обновлять автоматически';

  @override
  String get setPolicyOther => 'Обновления остальных компонентов';

  @override
  String get setPolicyHelp =>
      '«Автоматически» — проверить и установить при запуске; «Спрашивать» — показать значок обновления в «Компонентах»; «Никогда» — не проверять. Предыдущая версия сохраняется, к ней можно откатиться. По умолчанию: yt-dlp — автоматически, остальное — спрашивать.';

  @override
  String get policyAuto => 'Автоматически';

  @override
  String get policyAsk => 'Спрашивать';

  @override
  String get policyNever => 'Никогда';

  @override
  String get setKeepVersions => 'Хранить предыдущие версии';

  @override
  String get setKeepVersionsHint => 'Сколько старых версий оставить для отката';

  @override
  String get setKeepVersionsHelp =>
      'Каждая версия ffmpeg занимает 100–250 МБ. 0 — откат будет невозможен. По умолчанию: 2.';

  @override
  String get zoneLessDisk => 'меньше места';

  @override
  String get zoneMoreRollback => 'больше откатов';

  @override
  String get setNotify => 'Уведомлять о завершении';

  @override
  String get setNotifyHint => 'Системное уведомление, когда задача готова';

  @override
  String get setShowCommand => 'Показывать команду перед запуском';

  @override
  String get setShowCommandHint => 'Можно проверить и отредактировать команду ffmpeg';

  @override
  String get setShowCommandHelp =>
      'Перед добавлением в очередь откроется готовая команда ffmpeg: её можно скопировать, изменить и запустить. Кнопка «Показать команду» доступна у каждой задачи в любом случае. По умолчанию: выключено.';

  @override
  String get back => 'Назад';

  @override
  String get change => 'Изменить';

  @override
  String get apply => 'Применить';

  @override
  String get rename => 'Переименовать';

  @override
  String get save => 'Сохранить';

  @override
  String get none => 'нет';

  @override
  String get keepOriginal => 'Как в исходнике';

  @override
  String get stereo => 'Стерео';

  @override
  String get mono => 'Моно';

  @override
  String get toEnd => 'до конца';

  @override
  String get addToQueue => 'В очередь';

  @override
  String get runNow => 'Запустить';

  @override
  String get otherFile => 'Другой файл';

  @override
  String saveTo(String path) {
    return 'Сохранить в: $path';
  }

  @override
  String get chooseInputTitle => 'Выберите файл';

  @override
  String get commandEditHint => 'Можно изменить аргументы перед запуском (путь к ffmpeg подставится сам).';

  @override
  String get commandParseError => 'Незакрытая кавычка в команде';

  @override
  String get runCommand => 'Запустить';

  @override
  String stepLabel(String step) {
    return 'шаг $step';
  }

  @override
  String secondsShort(String value) {
    return '$value с';
  }

  @override
  String estimateSize(String size) {
    return '≈ $size';
  }

  @override
  String estimateAtMost(String size) {
    return 'не больше $size';
  }

  @override
  String get estimateDependsOnContent => 'Размер зависит от содержимого';

  @override
  String encoderLabel(String name) {
    return 'кодировщик $name';
  }

  @override
  String get issueNoEncoder =>
      'В установленной сборке ffmpeg нет кодировщика для этого кодека. Выберите другой кодек или установите full-сборку.';

  @override
  String get issueVideoContainer =>
      'Этот контейнер не поддерживает выбранный видеокодек. Выберите другой кодек или MKV.';

  @override
  String get issueAudioContainer =>
      'Этот контейнер не поддерживает выбранный аудиокодек. Выберите другой кодек или MKV.';

  @override
  String get issueCopyContainer =>
      'Исходный кодек нельзя скопировать в этот контейнер без перекодирования. Попробуйте MKV.';

  @override
  String get issueDurationUnknown => 'Длительность файла неизвестна, поэтому нельзя рассчитать размер или обрезку.';

  @override
  String get issueTargetTooSmall =>
      'Слишком маленький размер для такой длительности: на видео остаётся меньше 50 кбит/с. Увеличьте размер или уменьшите длительность.';

  @override
  String get issueNoTenBit => 'Этот кодировщик не умеет 10 бит — будет 8 бит.';

  @override
  String get issueNoAudio => 'В файле нет звуковой дорожки.';

  @override
  String get issueNoVideo => 'В файле нет видео.';

  @override
  String get issueChooseAudio => 'Выберите файл со звуком.';

  @override
  String get warnHdrSource =>
      'Исходник в HDR. Без 10 бит и тонмаппинга цвета будут блёклыми; полноценное HDR → SDR — в следующем этапе.';

  @override
  String get warnLongGif => 'GIF длиннее 20 секунд получится очень большим. Лучше WebP или видео.';

  @override
  String get groupFormat => 'Формат';

  @override
  String get groupVideo => 'Видео';

  @override
  String get groupAudio => 'Звук';

  @override
  String get groupOther => 'Прочее';

  @override
  String get groupTrim => 'Фрагмент';

  @override
  String get groupLoudness => 'Громкость';

  @override
  String get groupAnimation => 'Анимация';

  @override
  String get groupDownloadQuality => 'Качество';

  @override
  String get groupDownloadExtras => 'Дополнительно';

  @override
  String get presetsTitle => 'Пресеты';

  @override
  String get savePreset => 'Сохранить как пресет';

  @override
  String get presetNameLabel => 'Название пресета';

  @override
  String get builtinPresets => 'Встроенные';

  @override
  String get userPresets => 'Мои пресеты';

  @override
  String get userPresetsEmpty => 'Пока пусто. В «Конвертации» настройте параметры и нажмите «Сохранить как пресет».';

  @override
  String get importPresets => 'Импорт';

  @override
  String get exportPresets => 'Экспорт';

  @override
  String presetsImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Импортировано $count пресета',
      many: 'Импортировано $count пресетов',
      few: 'Импортировано $count пресета',
      one: 'Импортирован $count пресет',
    );
    return '$_temp0';
  }

  @override
  String presetsExported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Экспортировано $count пресета',
      many: 'Экспортировано $count пресетов',
      few: 'Экспортировано $count пресета',
      one: 'Экспортирован $count пресет',
    );
    return '$_temp0';
  }

  @override
  String get presetsImportFailed => 'Это не файл пресетов Kadra.';

  @override
  String get presetTelegram => 'Для Telegram';

  @override
  String get presetTelegramDesc => 'H.264 до 1080p, быстрый старт — проигрывается прямо в чате.';

  @override
  String get presetYoutube => 'Для YouTube';

  @override
  String get presetYoutubeDesc => 'Высокое качество (CRF 18), AAC 320 кбит/с 48 кГц — YouTube всё равно перекодирует.';

  @override
  String get presetDiscord => 'Для Discord (до 10 МБ)';

  @override
  String get presetDiscordDesc => 'Два прохода под 9,5 МБ, до 720p — влезает в бесплатный лимит.';

  @override
  String get presetEditProres => 'Для монтажа (ProRes)';

  @override
  String get presetEditProresDesc => 'ProRes 422 HQ + PCM: легко монтировать, файлы большие.';

  @override
  String get presetEditDnxhr => 'Для монтажа (DNxHR)';

  @override
  String get presetEditDnxhrDesc => 'DNxHR HQ + PCM для Avid и DaVinci Resolve.';

  @override
  String get presetArchive => 'Архив без потерь';

  @override
  String get presetArchiveDesc => 'FFV1 + FLAC в MKV: бит в бит, без потери качества.';

  @override
  String get presetMaxCompression => 'Максимальное сжатие';

  @override
  String get presetMaxCompressionDesc =>
      'AV1 10 бит + Opus: минимальный размер при хорошем качестве, но кодирует долго.';

  @override
  String get presetCompress => 'Просто сжать';

  @override
  String get presetCompressDesc => 'H.264, качество чуть ниже, до 1080p — обычно в 2–5 раз меньше.';

  @override
  String get codecCopy => 'Копировать (без перекодирования)';

  @override
  String get codecNoVideo => 'Без видео';

  @override
  String get codecNoAudio => 'Без звука';

  @override
  String get codecFfv1 => 'FFV1 (без потерь)';

  @override
  String get codecFlac => 'FLAC (без потерь)';

  @override
  String get codecAlac => 'ALAC (без потерь)';

  @override
  String get speedFastest => 'очень быстро';

  @override
  String get speedFast => 'быстро';

  @override
  String get speedMedium => 'средне';

  @override
  String get speedSlow => 'медленно';

  @override
  String get speedSlowest => 'очень медленно';

  @override
  String get rateQuality => 'Качество';

  @override
  String get rateBitrate => 'Битрейт';

  @override
  String get rateCbr => 'Постоянный';

  @override
  String get rateTargetSize => 'Размер файла';

  @override
  String get zoneBetterQuality => 'лучше качество';

  @override
  String get zoneSmallerFile => 'меньше размер';

  @override
  String get zoneSmoother => 'плавнее';

  @override
  String get pContainer => 'Контейнер (формат файла)';

  @override
  String get pContainerHint => 'Во что «упаковать» видео и звук';

  @override
  String get pContainerHelp =>
      'Контейнер — это «коробка», в которой лежат дорожки. MP4 открывается везде (телефоны, браузеры, мессенджеры). MKV принимает почти любые кодеки и субтитры — хорош для архива. MOV — для Apple и монтажа. WebM — для сайтов (VP9/AV1 + Opus). Для одного звука: MP3, M4A, Opus, FLAC, WAV. По умолчанию: MP4.';

  @override
  String get pVideoCodec => 'Видеокодек';

  @override
  String get pVideoCodecHint => 'Чем сжимать картинку';

  @override
  String get pVideoCodecHelp =>
      'H.264 — максимальная совместимость. H.265 — на 30–50% меньше при том же качестве, но не везде играет. AV1 — ещё меньше, кодирует медленнее (быстро на новых видеокартах). VP9 — для WebM. ProRes и DNxHR — для монтажа (большие файлы). FFV1 — без потерь. «Копировать» — мгновенно, без потери качества, если формат подходит. По умолчанию: H.264.';

  @override
  String get pAudioCodec => 'Аудиокодек';

  @override
  String get pAudioCodecHint => 'Чем сжимать звук';

  @override
  String get pHardware => 'Аппаратное кодирование';

  @override
  String pHardwareOn(String name) {
    return 'Используется видеокарта: $name';
  }

  @override
  String pHardwareOff(String name) {
    return 'Кодирует процессор: $name';
  }

  @override
  String get pHardwareHelp =>
      'Видеокарта (NVENC, Quick Sync, AMF, VAAPI) кодирует в 5–20 раз быстрее процессора, но при том же размере файла качество немного ниже. Для быстрых задач — включите, для архива и минимального размера — выключите. Если подходящей видеокарты нет, используется процессор. По умолчанию: включено.';

  @override
  String get pEncoder => 'Кодировщик';

  @override
  String get pEncoderHint => 'Конкретная реализация кодека из сборки ffmpeg';

  @override
  String get pRateMode => 'Режим';

  @override
  String get pRateModeHint => 'Как управлять размером и качеством';

  @override
  String get pRateModeHelp =>
      '«Качество» (CRF/CQ) — лучший выбор почти всегда: постоянное качество, размер подстраивается под сложность сцены. «Битрейт» — средний поток в кбит/с, предсказуемый размер. «Постоянный» — одинаковый поток для стриминга и старых плееров. «Размер файла» — укажите, сколько мегабайт должно получиться (например, лимит мессенджера), битрейт рассчитается сам, по возможности в два прохода. По умолчанию: «Качество».';

  @override
  String pQuality(String scale) {
    return 'Качество ($scale)';
  }

  @override
  String get pQualityHint => 'Меньше число — лучше качество и больше файл';

  @override
  String pQualityHelp(int value) {
    return 'Это «постоянное качество» кодировщика: каждая сцена кодируется так, чтобы выглядеть одинаково хорошо. Шаг в 6 единиц примерно вдвое меняет размер. Для x264: 18 — визуально без потерь, 23 — стандарт, 28 — заметно хуже. У AV1/VP9 шкала до 63. Значение по умолчанию для этого кодировщика: $value.';
  }

  @override
  String get pVideoBitrate => 'Битрейт видео';

  @override
  String get pVideoBitrateHint => 'Сколько килобит в секунду на видео';

  @override
  String get pVideoBitrateHelp =>
      'Ориентиры для H.264: 1080p — 4000–8000, 720p — 2500–5000, 480p — 1000–2000 кбит/с. H.265/AV1 нужно примерно на 30–50% меньше.';

  @override
  String get pTargetSize => 'Размер файла';

  @override
  String get pTargetSizeHint => 'Итоговый файл будет не больше этого';

  @override
  String get pTargetSizeHelp =>
      'Битрейт рассчитывается из длительности: (размер × 8) / секунды − звук, с запасом 3% на контейнер. Слишком маленький размер для длинного видео даст «мыло» — уменьшите разрешение. Discord: 10 МБ (ставьте 9,5), Telegram для ботов: 50 МБ.';

  @override
  String get pTwoPass => 'Два прохода';

  @override
  String get pTwoPassHint => 'Точнее попадает в размер, но вдвое дольше';

  @override
  String get pTwoPassHelp =>
      'Первый проход анализирует видео, второй распределяет биты: сложным сценам больше, простым меньше. Даёт лучшее качество при заданном размере. Для режима «Качество» не нужен. По умолчанию: включено.';

  @override
  String get pSpeed => 'Скорость кодирования';

  @override
  String get pSpeedHint => 'Медленнее — меньше файл при том же качестве';

  @override
  String get pSpeedHelp =>
      'Пресет скорости кодировщика (x264: veryfast…veryslow, NVENC: p1…p7, SVT-AV1: 12…4). Качество задаётся отдельно; медленный пресет лишь лучше сжимает. «Средне» — разумный баланс; «медленно» даёт −5–10% размера за ×2–3 времени. По умолчанию: средне.';

  @override
  String get pResolution => 'Разрешение';

  @override
  String get pResolutionHint => 'Уменьшить до этой высоты (не увеличивает)';

  @override
  String get pResolutionHelp =>
      'Пропорции сохраняются, ширина округляется до чётной. Уменьшение разрешения — самый эффективный способ сжать: 1080p → 720p уменьшает файл примерно вдвое. По умолчанию: как в исходнике.';

  @override
  String get pFps => 'Частота кадров';

  @override
  String get pFpsHint => 'Кадров в секунду';

  @override
  String get pTenBit => '10 бит';

  @override
  String get pTenBitHint => 'Меньше полос на градиентах, нужно для HDR';

  @override
  String get pTenBitHelp =>
      '10 бит на канал убирают «ступеньки» на небе и в тенях и немного улучшают сжатие у H.265/AV1. Старые устройства и некоторые браузеры H.264 10 бит не воспроизводят. По умолчанию: выключено.';

  @override
  String get pProfile => 'Профиль';

  @override
  String get pProfileHint => 'Ограничения совместимости кодека';

  @override
  String get pIntermediateProfileHint => 'Качество и размер монтажного формата';

  @override
  String get pIntermediateProfileHelp =>
      'ProRes: proxy < lt < standard < hq < 4444 < 4444xq. DNxHR: lb < sq < hq < hqx (10 бит) < 444. Для монтажа обычно хватает HQ. По умолчанию: HQ.';

  @override
  String get pTune => 'Настройка под содержимое';

  @override
  String get pTuneHint => 'Оптимизация под тип видео';

  @override
  String get pTuneHelp =>
      'film — живое видео, animation — мультфильмы, grain — сохранить зерно плёнки, stillimage — слайд-шоу, zerolatency — стриминг с минимальной задержкой. По умолчанию: нет.';

  @override
  String get pKeyint => 'Интервал ключевых кадров';

  @override
  String get pKeyintHint => 'Как часто можно начать воспроизведение с любого места';

  @override
  String get pKeyintHelp =>
      'Чем чаще ключевые кадры, тем быстрее перемотка и точнее быстрая обрезка, но файл больше. Для YouTube и стриминга рекомендуют 2 секунды. По умолчанию: авто (решает кодировщик).';

  @override
  String get pAudioBitrate => 'Битрейт звука';

  @override
  String get pAudioBitrateHint => 'Больше — лучше звук и больше файл';

  @override
  String get pAudioBitrateHelp =>
      'Ориентиры: AAC 128 — нормально для речи и музыки, 192–256 — для музыки, 320 — максимум. Opus звучит хорошо уже на 96. MP3 320 — предел формата. По умолчанию: зависит от кодека.';

  @override
  String get pChannels => 'Каналы';

  @override
  String get pChannelsHint => 'Например, свести 5.1 в стерео';

  @override
  String get pSampleRate => 'Частота дискретизации';

  @override
  String get pSampleRateHint => '48 кГц — видео, 44,1 кГц — музыка';

  @override
  String get pFaststart => 'Быстрый старт (faststart)';

  @override
  String get pFaststartHint => 'Видео начинает играть в браузере до полной загрузки';

  @override
  String get pFaststartHelp =>
      'Переносит индекс (moov) в начало MP4/MOV. Нужен для сайтов и мессенджеров, ничего не стоит. По умолчанию: включено.';

  @override
  String get pKeepSubs => 'Сохранить субтитры';

  @override
  String get pKeepSubsHint => 'Скопировать дорожки субтитров как есть';

  @override
  String get pKeepMetadata => 'Сохранить метаданные';

  @override
  String get pKeepMetadataHint => 'Теги, главы, дата съёмки. Выключите, чтобы удалить';

  @override
  String get pTrimMode => 'Способ обрезки';

  @override
  String get trimFast => 'Быстро';

  @override
  String get trimPrecise => 'Точно до кадра';

  @override
  String get trimFastHint => 'Мгновенно, без потери качества; начало — по ближайшему ключевому кадру';

  @override
  String get trimPreciseHint => 'Перекодирует фрагмент: точные границы, но дольше';

  @override
  String get pTrimModeHelp =>
      'Видео хранится группами кадров, которые начинаются с ключевого кадра. Быстрая обрезка копирует данные как есть, поэтому может начаться чуть раньше выбранной точки — до ближайшего ключевого кадра (обычно 0–5 секунд). Точная перекодирует фрагмент и режет ровно по кадру; качество почти не страдает.';

  @override
  String get pStart => 'Начало';

  @override
  String get pStartHint => 'ЧЧ:ММ:СС.мс или секунды';

  @override
  String get pEnd => 'Конец';

  @override
  String pEndHint(String total) {
    return 'Длительность файла: $total';
  }

  @override
  String keyframeStartHint(String time) {
    return 'Фактически начнётся с $time (ключевой кадр)';
  }

  @override
  String setStartHere(String time) {
    return 'Начало = $time';
  }

  @override
  String setEndHere(String time) {
    return 'Конец = $time';
  }

  @override
  String trimLength(String time) {
    return 'Фрагмент: $time';
  }

  @override
  String get pTrack => 'Дорожка';

  @override
  String get pTrackHint => 'Какую звуковую дорожку извлечь';

  @override
  String get pExtractFormat => 'Формат';

  @override
  String get pExtractFormatHint => 'Перекодировать в выбранный формат';

  @override
  String get pExtractFormatHelp =>
      '«Как есть» копирует звук без изменений — мгновенно и без потерь, формат файла подбирается под кодек. Выберите MP3/AAC/Opus, если нужен конкретный формат для плеера, FLAC/WAV — для обработки без потерь.';

  @override
  String get extractAsIs => 'Как есть (без перекодирования)';

  @override
  String extractCopyHint(String ext) {
    return 'Будет файл .$ext без потери качества';
  }

  @override
  String get pTrackMode => 'Что сделать';

  @override
  String get trackReplace => 'Заменить';

  @override
  String get trackAdd => 'Добавить';

  @override
  String get trackRemove => 'Удалить звук';

  @override
  String get trackReplaceHint => 'Убрать старый звук и поставить новый';

  @override
  String get trackAddHint => 'Оставить старые дорожки и добавить ещё одну (например, перевод)';

  @override
  String get trackRemoveHint => 'Сделать видео без звука';

  @override
  String get pAudioFile => 'Файл со звуком';

  @override
  String get pAudioFileHint => 'Можно взять звук из любого аудио- или видеофайла';

  @override
  String get pShortest => 'По самой короткой дорожке';

  @override
  String get pShortestHint => 'Обрезать результат, когда кончится видео или звук';

  @override
  String get pLanguage => 'Язык дорожки';

  @override
  String get pLanguageHint => 'Плееры покажут его при выборе дорожки';

  @override
  String get losslessVideoTag => 'видео без перекодирования';

  @override
  String get videoCopiedNote => 'Видео копируется — быстро и без потери качества';

  @override
  String get pLoudTarget => 'Целевая громкость';

  @override
  String pLoudTargetHint(String lufs, String tp) {
    return '$lufs LUFS, пики не выше $tp dBTP';
  }

  @override
  String get pLoudTargetHelp =>
      'LUFS — воспринимаемая громкость. Площадки сами приглушают слишком громкое, поэтому лучше сразу попасть в их цель: YouTube и Spotify −14, подкасты (Apple) −16, ТВ по EBU R128 −23. True Peak ограничивает пики, чтобы не было искажений после сжатия в MP3/AAC.';

  @override
  String get loudStreaming => 'YouTube, Spotify';

  @override
  String get loudPodcast => 'Подкаст';

  @override
  String get loudBroadcast => 'ТВ (EBU R128)';

  @override
  String get loudApple => 'Apple Music';

  @override
  String get pTwoPassLoud => 'Двухпроходная нормализация';

  @override
  String get pTwoPassLoudOn => 'Сначала измерить, затем точно привести громкость';

  @override
  String get pTwoPassLoudOff => 'Один проход: быстрее, но с динамической подстройкой';

  @override
  String get pTwoPassLoudHelp =>
      'Первый проход измеряет громкость всего файла, второй применяет одно и то же усиление ко всему — динамика не меняется, результат точно в цели. Однопроходный режим подстраивает громкость на лету и может «качать» звук. По умолчанию: два прохода.';

  @override
  String normalizeNote(String codec) {
    return 'Звук будет перекодирован ($codec), видео скопировано';
  }

  @override
  String get pAnimFormat => 'Формат';

  @override
  String get pAnimFormatHint => 'GIF работает везде, WebP и APNG — качественнее и меньше';

  @override
  String get pAnimFormatHelp =>
      'GIF ограничен 256 цветами, поэтому для него строится оптимальная палитра под конкретное видео. WebP даёт полноцветную анимацию в 2–5 раз меньше. APNG — без потерь, но тяжёлый. По умолчанию: GIF.';

  @override
  String get pDuration => 'Длительность';

  @override
  String get pDurationHint => 'Пусто — до конца файла';

  @override
  String get pGifFps => 'Кадров в секунду';

  @override
  String get pGifFpsHint => '10–15 обычно достаточно';

  @override
  String get pGifWidth => 'Ширина';

  @override
  String get pGifWidthHint => 'Высота подберётся по пропорциям';

  @override
  String get pDither => 'Дизеринг';

  @override
  String get pDitherHint => 'Как имитировать недостающие цвета';

  @override
  String get pDitherHelp =>
      'Sierra — мягкий и аккуратный (по умолчанию). Floyd–Steinberg — больше деталей, больше «шума». Bayer — регулярный узор, хорошо сжимается. Без дизеринга — полосы на градиентах, но меньше файл.';

  @override
  String get pStaticBg => 'Статичный фон';

  @override
  String get pStaticBgHint => 'Лучше цвета, если двигается только часть кадра';

  @override
  String get pWebpQuality => 'Качество WebP';

  @override
  String get pWebpQualityHint => '75 — хороший баланс';

  @override
  String get pLoop => 'Зациклить';

  @override
  String get pLoopHint => 'Повторять анимацию бесконечно';

  @override
  String gifFrames(int count) {
    return '$count кадров';
  }

  @override
  String get urlsLabel => 'Ссылки';

  @override
  String get urlsHint => 'Вставьте одну или несколько ссылок (на видео, плейлист или канал)';

  @override
  String pasteFromClipboard(String url) {
    return 'Вставить из буфера: $url';
  }

  @override
  String get analyzeLinks => 'Получить информацию';

  @override
  String get downloadWithoutAnalysis => 'Скачать сразу';

  @override
  String get download => 'Скачать';

  @override
  String downloadN(int count) {
    return 'Скачать ($count)';
  }

  @override
  String downloadsQueued(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'В очередь добавлено $count загрузки',
      many: 'В очередь добавлено $count загрузок',
      few: 'В очередь добавлено $count загрузки',
      one: 'В очередь добавлена $count загрузка',
    );
    return '$_temp0';
  }

  @override
  String get downloadsNeedYtdlpTitle => 'Нужен yt-dlp';

  @override
  String get denoHint => 'Совет: для YouTube установите Deno в «Компонентах» — без него часть форматов недоступна.';

  @override
  String selectedOf(int selected, int total) {
    return 'Выбрано $selected из $total';
  }

  @override
  String get selectAll => 'Все';

  @override
  String get selectNone => 'Ни одного';

  @override
  String get rangesHint => 'Номера: 1,3,5-10';

  @override
  String availableQualities(String list) {
    return 'Есть: $list';
  }

  @override
  String get exactFormat => 'Точный формат (необязательно)';

  @override
  String get exactFormatAuto => 'Автоматически по качеству ниже';

  @override
  String get videoOnly => 'только видео';

  @override
  String get pYtQuality => 'Качество';

  @override
  String get pYtQualityHint => 'Лучшее доступное или не выше выбранного';

  @override
  String get ytBest => 'Лучшее';

  @override
  String ytUpTo(String height) {
    return 'до $height';
  }

  @override
  String get ytAudioOnly => 'Только звук';

  @override
  String get pYtAudioFormat => 'Формат звука';

  @override
  String get pYtAudioFormatHint => 'В какой формат сохранить звук';

  @override
  String get pYtContainerHint => 'MP4 — для совместимости, MKV — без ограничений';

  @override
  String get pYtContainerHelp =>
      'Сайты часто отдают видео и звук отдельно; yt-dlp склеивает их через ffmpeg в выбранный контейнер. Для MP4 предпочитаются H.264/AAC, чтобы не перекодировать. «Как на сайте» сохраняет исходный формат (часто WebM).';

  @override
  String get ytContainerAuto => 'Как на сайте';

  @override
  String get pYtSubs => 'Субтитры';

  @override
  String get pYtSubsHint => 'Скачать и вшить субтитры авторов';

  @override
  String get pYtAutoSubs => 'Автоматические субтитры';

  @override
  String get pYtAutoSubsHint => 'Сгенерированные сайтом (например, YouTube)';

  @override
  String get pYtSubLangs => 'Языки субтитров';

  @override
  String get pYtSubLangsHint => 'Через запятую: ru,en или all';

  @override
  String get pYtEmbed => 'Обложка, метаданные и главы';

  @override
  String get pYtEmbedHint => 'Вшить в файл';

  @override
  String get pSponsorBlock => 'SponsorBlock';

  @override
  String get pSponsorBlockHint => 'Рекламные вставки авторов';

  @override
  String get pSponsorBlockHelp =>
      'Использует базу sponsor.ajay.app. «Отметить» добавляет главы, «Вырезать» удаляет спонсорские вставки, саморекламу и просьбы подписаться (требует перекодирования фрагментов).';

  @override
  String get sbOff => 'Не трогать';

  @override
  String get sbMark => 'Отметить главами';

  @override
  String get sbRemove => 'Вырезать';

  @override
  String get pCookies => 'Cookies из браузера';

  @override
  String get pCookiesHint => 'Для приватных, 18+ и «подтвердите, что вы не бот»';

  @override
  String get pCookiesHelp =>
      'yt-dlp прочитает cookies входа из выбранного браузера, как будто видео открыли в нём. Браузер лучше закрыть (Chrome блокирует файл cookies). Cookies никуда не отправляются, кроме самого сайта.';

  @override
  String get pArchive => 'Не качать повторно';

  @override
  String get pArchiveHint => 'Вести список скачанного в папке загрузок';

  @override
  String get pTemplate => 'Шаблон имени файла';

  @override
  String get pTemplateHint => 'Поля yt-dlp: %(title)s, %(id)s, %(uploader)s…';

  @override
  String get pTemplateHelp =>
      'Например: «%(uploader)s/%(title)s.%(ext)s» разложит видео по папкам каналов. Полный список полей — в документации yt-dlp (OUTPUT TEMPLATE).';

  @override
  String get pRateLimit => 'Ограничение скорости';

  @override
  String get pRateLimitHint => 'Например 5M = 5 МБ/с; пусто — без ограничения';

  @override
  String get pProxy => 'Прокси';

  @override
  String get pProxyHint => 'http://, https:// или socks5://';

  @override
  String get setNextToSource => 'Сохранять рядом с исходным';

  @override
  String get setNextToSourceHint => 'Результат в той же папке, что и исходный файл';

  @override
  String get setAria2 => 'Загрузка через aria2c';

  @override
  String get setAria2Hint => 'Многопоточная загрузка, если aria2c установлен';

  @override
  String get setAria2Help =>
      'aria2c открывает несколько соединений к серверу и часто качает быстрее на медленных серверах. Для YouTube обычно хватает встроенных параллельных фрагментов. По умолчанию: выключено.';
}
