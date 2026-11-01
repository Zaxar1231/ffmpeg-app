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
}
