"""Source of the UI strings: `python3 tool/l10n/arb.py && flutter gen-l10n`.

Every string is declared once with k(key, ru, en, **placeholders) and
written to lib/l10n/app_ru.arb (template) and app_en.arb.
"""
import json, os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
S = {}  # key -> (ru, en, placeholders)
def k(key, ru, en, **ph): S[key] = (ru, en, ph)

k('appTitle','Kadra','Kadra')
# navigation
k('navHome','Главная','Home'); k('navTools','Инструменты','Tools'); k('navDownloads','Загрузки','Downloads')
k('navQueue','Очередь','Queue'); k('navPresets','Пресеты','Presets'); k('navComponents','Компоненты','Components'); k('navSettings','Настройки','Settings')
# generic
k('cancel','Отмена','Cancel'); k('close','Закрыть','Close'); k('copy','Копировать','Copy'); k('copied','Скопировано','Copied')
k('choose','Выбрать','Choose'); k('search','Поиск','Search'); k('more','Ещё','More'); k('auto','авто','auto'); k('notSet','Не задано','Not set')
k('nothingFound','Ничего не найдено','Nothing found'); k('helpTooltip','Подробнее','Details'); k('resetTooltip','Сбросить','Reset')
k('resetSection','Сбросить раздел','Reset section'); k('resetAll','Сбросить все настройки','Reset all settings')
k('install','Установить','Install'); k('update','Обновить','Update'); k('reinstall','Переустановить','Reinstall'); k('rollback','Откатить','Roll back')
k('remove','Удалить','Remove'); k('activate','Сделать активной','Activate'); k('reload','Перечитать файл','Reload file')
k('pause','Пауза','Pause'); k('resume','Продолжить','Resume'); k('retry','Повторить','Retry'); k('openFolder','Открыть папку','Open folder')
k('showLog','Показать лог','Show log'); k('showCommand','Показать команду','Show command'); k('removeFromList','Убрать из списка','Remove from list')
k('logTitle','Полный лог','Full log'); k('commandTitle','Команда','Command')
# units
k('unitB','Б','B'); k('unitKB','КБ','KB'); k('unitMB','МБ','MB'); k('unitGB','ГБ','GB'); k('unitTB','ТБ','TB')
k('unitKbps','кбит/с','kb/s'); k('unitMbps','Мбит/с','Mb/s'); k('unitFps','к/с','fps'); k('unitHz','Гц','Hz'); k('unitSecond','с','s')
# home
k('homeTitle','Главная','Home'); k('openFile','Открыть файл','Open file'); k('closeFile','Закрыть файл','Close file')
k('dropTitle','Перетащите файл сюда','Drop a file here'); k('dropSubtitle','или нажмите, чтобы выбрать: видео, аудио, картинка','or click to choose: video, audio, image')
k('shortcutOpenHint','Ctrl+O — открыть файл, Ctrl+1…7 — разделы','Ctrl+O opens a file, Ctrl+1…7 switch sections')
k('probeFailed','Не удалось прочитать файл','Could not read the file'); k('openAnother','Открыть другой','Open another')
k('quickActions','Быстрые действия','Quick actions')
k('ffmpegMissingTitle','ffmpeg не найден','ffmpeg not found')
k('ffmpegMissingBody','Без него приложение не может работать с файлами. Установите ffmpeg в разделе «Компоненты» — это займёт минуту.','The app cannot process files without it. Install ffmpeg in Components; it takes a minute.')
k('openComponents','Открыть «Компоненты»','Open Components')
k('addedToQueue','Задача добавлена в очередь','Job added to the queue'); k('openQueue','Открыть очередь','Open queue')
# media info
k('infoContainer','Контейнер','Container'); k('infoFormat','Формат','Format'); k('infoDuration','Длительность','Duration'); k('infoSize','Размер','Size')
k('infoBitrate','Битрейт','Bitrate'); k('infoStartTime','Начало','Start time'); k('infoStreams','Потоков','Streams')
k('infoChapters','{count, plural, one{{count} глава} few{{count} главы} many{{count} глав} other{{count} главы}}','{count, plural, one{{count} chapter} other{{count} chapters}}', count='int')
k('infoTags','Теги','Tags'); k('infoCodec','Кодек','Codec'); k('infoResolution','Разрешение','Resolution'); k('infoFrameRate','Частота кадров','Frame rate')
k('infoPixelFormat','Пиксельный формат','Pixel format'); k('infoBits','{bits} бит','{bits}-bit', bits='int'); k('infoColor','Цвет','Color')
k('infoFieldOrder','Развёртка','Field order'); k('infoRotation','Поворот','Rotation'); k('infoMastering','Мастеринг HDR','HDR mastering')
k('infoContentLight','Уровни яркости','Content light'); k('infoSampleRate','Частота дискретизации','Sample rate'); k('infoChannels','Каналы','Channels')
k('infoSampleFormat','Формат сэмплов','Sample format'); k('infoFrames','Кадров','Frames'); k('infoVersion','Версия','Version')
k('streamVideo','Видео','Video'); k('streamAudio','Аудио','Audio'); k('streamSubtitle','Субтитры','Subtitles'); k('streamCover','Обложка','Cover art')
k('streamAttachment','Вложение','Attachment'); k('streamData','Данные','Data')
k('dispositionDefault','по умолчанию','default'); k('dispositionForced','принудительные','forced')
# tools page
k('toolsSearchHint','Найти инструмент: «сжать», «gif», «субтитры»…','Find a tool: "compress", "gif", "subtitles"…')
k('toolComingSoon','Появится на этапе {stage} разработки','Coming in development stage {stage}', stage='int')
k('stageLabel','этап {stage}','stage {stage}', stage='int')
k('losslessTag','мгновенно, без потери качества','instant, lossless')
k('needsOtherBuild','нужна другая сборка','needs another build')
k('needsBuildTooltip','В установленной сборке ffmpeg нет: {names}. Установите full-сборку в «Компонентах».','The installed ffmpeg build lacks: {names}. Install a full build in Components.', names='String')
cats = {'Analysis':('Анализ и информация','Analysis'),'Convert':('Конвертация и сжатие','Convert & compress'),'Edit':('Монтаж и редактирование','Editing'),
 'Audio':('Аудио','Audio'),'Subtitles':('Субтитры','Subtitles'),'Images':('Изображения и анимация','Images & animation'),'Metadata':('Метаданные и главы','Metadata & chapters'),
 'Capture':('Запись и стриминг','Capture & streaming'),'Repair':('Ремонт файлов','Repair'),'Download':('Загрузка видео','Download'),'Automation':('Пакетная обработка','Batch & automation'),'Expert':('Режим эксперта','Expert')}
for c,(r,e) in cats.items(): k('cat'+c, r, e)
tools = [
 ('MediaInfo','Информация о файле','File info','Контейнер, потоки, кодеки, битрейт, HDR, главы и теги.','Container, streams, codecs, bitrate, HDR, chapters and tags.'),
 ('Integrity','Проверка целостности','Integrity check','Декодирует файл целиком и перечисляет все найденные ошибки.','Decodes the whole file and lists every error found.'),
 ('Loudness','Замер громкости','Loudness meter','LUFS, True Peak и LRA по стандарту EBU R128.','LUFS, True Peak and LRA per EBU R128.'),
 ('Waveform','Осциллограмма и спектр','Waveform & spectrum','Картинка с формой волны или спектрограммой звука.','An image of the waveform or spectrogram.'),
 ('Detect','Детекторы','Detectors','Тишина, чёрные и замершие кадры, смена сцен, чёрные поля.','Silence, black and frozen frames, scene changes, black borders.'),
 ('CompareQuality','Сравнение качества','Quality comparison','VMAF, PSNR и SSIM между оригиналом и результатом.','VMAF, PSNR and SSIM between original and result.'),
 ('Convert','Конвертация','Convert','Любой контейнер и кодек: MP4, MKV, WebM, MP3, FLAC и другие.','Any container and codec: MP4, MKV, WebM, MP3, FLAC and more.'),
 ('Compress','Сжатие','Compress','Уменьшить размер: по качеству или до заданного размера файла.','Shrink files by quality or to a target file size.'),
 ('HdrToSdr','HDR → SDR','HDR → SDR','Тонмаппинг HDR-видео для обычных экранов.','Tone-map HDR video for regular screens.'),
 ('Trim','Обрезка','Trim','Быстро по ключевым кадрам или точно до кадра.','Fast on keyframes or frame-accurate.'),
 ('CutJoin','Вырезать фрагменты','Cut fragments','Удалить лишние куски или оставить только нужные.','Remove unwanted parts or keep only selected ones.'),
 ('Concat','Склейка','Join','Соединить несколько файлов в один.','Join several files into one.'),
 ('Split','Разделение','Split','По времени, на равные части, по главам или по отмеченным точкам.','By length, into equal parts, by chapters or at marked points.'),
 ('CropScale','Кадр и размер','Crop & scale','Кадрирование, масштаб, поворот, вертикальное видео.','Crop, scale, rotate, vertical video.'),
 ('Speed','Скорость и FPS','Speed & FPS','Ускорение, замедление, реверс, интерполяция кадров.','Speed up, slow down, reverse, frame interpolation.'),
 ('Restore','Улучшение видео','Restore video','Деинтерлейс, стабилизация, шумоподавление, резкость.','Deinterlace, stabilize, denoise, sharpen.'),
 ('Color','Цвет','Color','Яркость, контраст, кривые, 3D LUT, ч/б и сепия.','Brightness, contrast, curves, 3D LUT, B&W and sepia.'),
 ('Overlay','Водяной знак и текст','Watermark & text','Картинка, текст или таймкод поверх видео.','Image, text or timecode over the video.'),
 ('Blur','Размытие и логотипы','Blur & logos','Размыть или пикселизовать область, убрать логотип.','Blur or pixelate an area, remove a logo.'),
 ('Stack','Картинка в картинке','Picture in picture','PiP, сетка, сравнение бок о бок.','PiP, grid, side-by-side comparison.'),
 ('Transitions','Затухания и переходы','Fades & transitions','Fade in/out и все виды переходов xfade.','Fade in/out and every xfade transition.'),
 ('Loop','Кольцевание','Loop','Повтор видео и бумеранг.','Loop video and boomerang.'),
 ('ExtractAudio','Извлечь звук','Extract audio','Сохранить звуковую дорожку отдельным файлом.','Save the audio track as a separate file.'),
 ('ReplaceAudio','Дорожки звука','Audio tracks','Заменить, добавить, удалить дорожку или выбрать основную.','Replace, add, remove tracks or set the default one.'),
 ('Normalize','Нормализация громкости','Loudness normalization','Двухпроходная loudnorm: YouTube −14, подкаст −16, ТВ −23 LUFS.','Two-pass loudnorm: YouTube −14, podcast −16, TV −23 LUFS.'),
 ('Denoise','Шумоподавление','Noise reduction','afftdn, anlmdn, RNNoise, удаление щелчков и клиппинга.','afftdn, anlmdn, RNNoise, declick and declip.'),
 ('AudioFx','Обработка звука','Audio effects','Эквалайзер, компрессор, лимитер, темп и тон, каналы.','EQ, compressor, limiter, tempo and pitch, channels.'),
 ('Mix','Смешивание','Mixing','Несколько дорожек вместе, автоприглушение музыки под голос.','Mix tracks, duck music under voice.'),
 ('Transcribe','Транскрипция','Transcription','Распознать речь в субтитры через whisper.','Speech to subtitles with whisper.'),
 ('BurnSubs','Вшить субтитры','Burn subtitles','Субтитры прямо в картинке, со стилями.','Subtitles drawn into the picture, styled.'),
 ('SoftSubs','Дорожки субтитров','Subtitle tracks','Добавить, извлечь или удалить отдельную дорожку.','Add, extract or remove a subtitle track.'),
 ('ConvertSubs','Конвертация субтитров','Convert subtitles','SRT ↔ ASS ↔ VTT, сдвиг таймингов, кодировка.','SRT ↔ ASS ↔ VTT, timing shift, encoding.'),
 ('Gif','GIF и анимации','GIF & animations','Качественный GIF с палитрой, анимированные WebP и APNG.','High-quality palette GIF, animated WebP and APNG.'),
 ('Frames','Извлечь кадры','Extract frames','Каждый N-й кадр, по сценам или в заданное время.','Every Nth frame, by scene or at given times.'),
 ('ContactSheet','Раскадровка','Contact sheet','Сетка миниатюр из видео.','A grid of thumbnails from the video.'),
 ('Slideshow','Слайд-шоу','Slideshow','Видео из картинок с переходами.','Video from images with transitions.'),
 ('AudioToVideo','Картинка + звук','Image + audio','Видео из обложки и аудио, например для YouTube.','Video from a cover and audio, e.g. for YouTube.'),
 ('Visualizer','Визуализатор звука','Audio visualizer','Волна, спектр или вектороскоп в видео.','Waves, spectrum or vectorscope as video.'),
 ('ImageConvert','Конвертация картинок','Convert images','JPEG, PNG, WebP, AVIF: сжатие и смена формата.','JPEG, PNG, WebP, AVIF: compress and convert.'),
 ('Tags','Теги','Tags','Название, исполнитель, альбом, год и прочее.','Title, artist, album, year and more.'),
 ('Cover','Обложка','Cover art','Добавить, заменить или извлечь обложку.','Add, replace or extract cover art.'),
 ('Chapters','Главы','Chapters','Добавить, переименовать, импорт и экспорт глав.','Add, rename, import and export chapters.'),
 ('ScreenRecord','Запись экрана','Screen recording','Весь экран или его часть, с микрофоном и звуком компьютера.','Full screen or a region, with microphone and computer audio.'),
 ('Webcam','Камера и микрофон','Camera & mic','Запись с веб-камеры и микрофона.','Record from webcam and microphone.'),
 ('Stream','Стрим','Streaming','RTMP / SRT на YouTube, Twitch или свой сервер.','RTMP / SRT to YouTube, Twitch or your server.'),
 ('Hls','HLS / DASH','HLS / DASH','Упаковка для воспроизведения в браузере.','Packaging for web playback.'),
 ('Repair','Ремонт','Repair','Ремукс битых файлов, таймстемпы, рассинхрон.','Remux broken files, timestamps, A/V sync.'),
 ('Faststart','Faststart для MP4','MP4 faststart','Быстрый старт видео в браузере.','Fast start for web playback.'),
 ('Download','Загрузка по ссылке','Download from link','Видео и аудио с сайтов через yt-dlp.','Video and audio from websites via yt-dlp.'),
 ('Batch','Пакетная обработка','Batch processing','Одна операция для папки или набора файлов.','One operation for a folder or many files.'),
 ('Recipes','Рецепты','Recipes','Цепочки операций: обрезать → нормализовать → сжать.','Operation chains: trim → normalize → compress.'),
 ('WatchFolder','Наблюдение за папкой','Watch folder','Новые файлы обрабатываются автоматически.','New files are processed automatically.'),
 ('CommandEditor','Редактор команд','Command editor','Своя команда ffmpeg с автодополнением.','Your own ffmpeg command with completion.'),
 ('FilterGraph','Конструктор фильтров','Filter graph builder','Цепочка фильтров списком с параметрами.','A filter chain as a list with parameters.'),
 ('CommandLog','Журнал команд','Command log','Все запущенные команды с логами.','Every command run, with logs.'),
]
for tid, ru, en, rud, end in tools:
    k('tool'+tid, ru, en); k('tool'+tid+'Desc', rud, end)
# queue
k('queueEmptyTitle','Очередь пуста','The queue is empty'); k('queueEmptyBody','Задачи из инструментов появятся здесь с прогрессом, скоростью и оставшимся временем.','Jobs from tools appear here with progress, speed and time left.')
k('queueActive','В работе и в очереди','Active and queued'); k('queueHistory','История','History'); k('clearFinished','Очистить завершённые','Clear finished')
k('parallelJobsShort','Параллельно: {count}','Parallel: {count}', count='int')
k('statusQueued','В очереди','Queued'); k('statusRunning','Выполняется','Running'); k('statusPaused','Пауза','Paused'); k('statusCompleted','Готово','Done')
k('statusCompletedWithFindings','{count, plural, one{Найдена {count} проблема} few{Найдено {count} проблемы} many{Найдено {count} проблем} other{Найдено {count} проблемы}}','{count, plural, one{{count} problem found} other{{count} problems found}}', count='int')
k('statusNoProblems','Ошибок не найдено','No problems found')
k('statusFailed','Ошибка','Failed'); k('statusCanceled','Отменено','Canceled')
k('etaLabel','осталось {time}','{time} left', time='String'); k('tookLabel','заняло {time}','took {time}', time='String')
k('attemptsLabel','{count, plural, one{{count} попытка} few{{count} попытки} many{{count} попыток} other{{count} попытки}}','{count, plural, one{{count} attempt} other{{count} attempts}}', count='int')
k('priorityHigh','Высокий приоритет','High priority'); k('priorityRaise','Поднять приоритет','Raise priority'); k('priorityNormal','Обычный приоритет','Normal priority')
# errors
k('errToolMissing','Не найден нужный инструмент. Установите его в разделе «Компоненты».','A required tool was not found. Install it in Components.')
k('errFileNotFound','Файл не найден: {path}','File not found: {path}', path='String')
k('errPermissionDenied','Нет доступа к файлу или папке: {path}. Выберите другую папку для сохранения.','No access to file or folder: {path}. Choose another output folder.', path='String')
k('errDiskFull','Закончилось место на диске.','The disk is full.')
k('errInvalidData','Файл повреждён или его формат не поддерживается. Попробуйте «Ремонт» или «Проверку целостности».','The file is damaged or its format is not supported. Try Repair or Integrity check.')
k('errEncoderMissing','В этой сборке ffmpeg нет кодировщика «{name}». Выберите другой кодек или установите full-сборку.','This ffmpeg build has no "{name}" encoder. Pick another codec or install a full build.', name='String')
k('errDecoderMissing','В этой сборке ffmpeg нет декодера «{name}».','This ffmpeg build has no "{name}" decoder.', name='String')
k('errFilterMissing','В этой сборке ffmpeg нет фильтра «{name}». Установите full-сборку в «Компонентах».','This ffmpeg build has no "{name}" filter. Install a full build in Components.', name='String')
k('errCodecContainer','Кодек не поддерживается этим контейнером. Попробуйте MKV — он принимает почти всё.','The codec is not supported by this container. Try MKV: it accepts almost anything.')
k('errOddDimensions','Ширина и высота должны быть чётными для этого кодека. Включите округление размера.','Width and height must be even for this codec. Enable size rounding.')
k('errHwUnavailable','Аппаратный кодировщик недоступен (нет видеокарты или драйвера). Отключите ускорение или выберите программный кодек.','The hardware encoder is unavailable (no GPU or driver). Disable acceleration or pick a software codec.')
k('errInvalidArgument','Неверный параметр: {arg}','Invalid option: {arg}', arg='String')
k('errStreamNotFound','В файле нет выбранной дорожки.','The selected track does not exist in the file.')
k('errSameAsInput','Результат нельзя записать поверх исходного файла. Выберите другое имя.','The output cannot overwrite the input. Choose another name.')
k('errNetwork','Проблема с сетью. Проверьте подключение и попробуйте снова.','Network problem. Check your connection and try again.')
k('errUnsupportedUrl','Этот сайт или ссылка не поддерживаются.','This site or link is not supported.')
k('errLoginRequired','Нужен вход в аккаунт. Включите cookies из браузера в настройках загрузок.','Login required. Enable browser cookies in download settings.')
k('errVideoUnavailable','Видео недоступно: удалено, приватное или заблокировано в регионе.','The video is unavailable: removed, private or region-blocked.')
k('errLoudnessMeasure','Не удалось измерить громкость: в файле тишина или нет звука.','Could not measure loudness: the audio is silent or missing.')
k('errCanceled','Отменено.','Canceled.'); k('errUnknown','Не получилось. Подробности в полном логе.','It did not work. See the full log for details.')
# components
k('checkUpdates','Проверить обновления','Check for updates'); k('lastChecked','Проверено в {time}','Checked at {time}', time='String')
k('compFfmpeg','ffmpeg и ffprobe','ffmpeg & ffprobe'); k('compFfmpegDesc','Основной движок: конвертация, фильтры, анализ. Обязателен.','The core engine: conversion, filters, analysis. Required.')
k('compYtdlp','yt-dlp','yt-dlp'); k('compYtdlpDesc','Загрузка видео и аудио с YouTube и тысяч других сайтов.','Downloads video and audio from YouTube and thousands of sites.')
k('compDeno','Deno','Deno'); k('compDenoDesc','JavaScript-рантайм, который нужен yt-dlp для YouTube.','JavaScript runtime that yt-dlp needs for YouTube.')
k('compAria2','aria2c','aria2c'); k('compAria2Desc','Ускоренная многопоточная загрузка для yt-dlp.','Faster multi-connection downloads for yt-dlp.')
k('originCustom','свой путь','custom path'); k('originManaged','установлен приложением','installed by app'); k('originSystem','системный','system'); k('originNone','не найден','not found')
k('updateAvailable','есть обновление','update available'); k('inUse','Используется','In use'); k('installedVersion','Версия','Version')
k('sourceLabel','Источник','Source'); k('latestAvailable','Доступно','Available'); k('noChecksum','издатель не публикует SHA-256','publisher provides no SHA-256')
k('removeComponentConfirm','Удалить «{name}» и все сохранённые версии?','Remove "{name}" and all saved versions?', name='String')
k('componentError','Ошибка: {error}','Error: {error}', error='String')
k('versionHistory','{count, plural, one{Установленные версии ({count})} other{Установленные версии ({count})}}','{count, plural, one{Installed versions ({count})} other{Installed versions ({count})}}', count='int')
k('phaseResolving','Поиск последней версии…','Looking up the latest version…'); k('phaseDownloading','Скачивание','Downloading'); k('phaseVerifying','Проверка SHA-256…','Verifying SHA-256…')
k('phaseExtracting','Распаковка…','Extracting…'); k('phaseTesting','Проверка запуска…','Testing the binary…')
k('flavorFull','full','full'); k('flavorEssentials','essentials','essentials')
k('channelRelease','релиз','release'); k('channelNightly','nightly','nightly'); k('channelStable','stable','stable')
k('btbnHint','Статические сборки BtbN. GPL — всё, включая x264/x265; LGPL — без GPL-кодеков.','BtbN static builds. GPL has everything incl. x264/x265; LGPL omits GPL codecs.')
k('gyanHint','Сборки gyan.dev для Windows. full — максимум фильтров и кодеков (whisper, vmaf, frei0r).','gyan.dev Windows builds. full has the most filters and codecs (whisper, vmaf, frei0r).')
k('customPathNone','Можно указать свой бинарник вместо загруженного.','You can point to your own binary instead.')
k('customPathValue','Используется свой путь: {path}','Using custom path: {path}', path='String')
k('useCustomBinary','Указать свой','Use my own')
k('installViaPackageManager','Установите пакет «{pkg}» через менеджер пакетов системы.','Install the "{pkg}" package with your system package manager.', pkg='String')
k('buildInfoTitle','Возможности сборки ffmpeg','ffmpeg build capabilities'); k('licenseLabel','Лицензия','License')
k('encoders','Кодировщики','Encoders'); k('decoders','Декодеры','Decoders'); k('filters','Фильтры','Filters'); k('muxers','Контейнеры','Muxers'); k('configuration','Конфигурация','Configuration')
k('hwTitle','Аппаратное ускорение','Hardware acceleration'); k('redetect','Перепроверить','Re-detect'); k('hwDetecting','Пробное кодирование на каждом ускорителе…','Trial-encoding on each accelerator…')
k('hwDecode','Декодирование','Decoding'); k('hwBestDecode','Лучшее для декодирования','Best for decoding'); k('hwEncoders','Рабочие кодировщики','Working encoders')
k('hwSoftwareOnly','только программно','software only'); k('hwNoneWorking','не найдено, кодирование будет на процессоре','none, encoding will use the CPU')
k('hwFailed','{count, plural, one{Не прошёл проверку: {count}} other{Не прошли проверку: {count}}}','{count, plural, one{{count} failed the check} other{{count} failed the check}}', count='int')
k('plannedComponents','Скоро','Coming soon')
k('compRnnoise','Модели RNNoise (шумоподавление голоса)','RNNoise models (voice denoise)'); k('compVmaf','Модели VMAF (оценка качества)','VMAF models (quality metrics)')
k('compWhisper','Модели whisper.cpp (транскрипция)','whisper.cpp models (transcription)'); k('compFrei0r','frei0r и LADSPA/LV2 плагины','frei0r and LADSPA/LV2 plugins')
k('compLuts','3D LUT-пакеты (.cube)','3D LUT packs (.cube)'); k('compFonts','Шрифты для субтитров и текста','Fonts for subtitles and text')
# downloads/presets
k('downloadsSoonTitle','Загрузка по ссылкам — на этапе 2','Link downloads arrive in stage 2')
k('downloadsReady','yt-dlp готов: {path}','yt-dlp is ready: {path}', path='String')
k('downloadsNeedYtdlp','Для загрузки понадобится yt-dlp. Его можно установить уже сейчас.','Downloads need yt-dlp. You can install it now.')
k('presetsSoonTitle','Пресеты появятся вместе с конвертацией','Presets arrive with conversion tools')
k('presetsSoonBody','«Для Telegram», «Для YouTube», «Для Discord (до 10 МБ)», «Для монтажа», «Архив без потерь» и свои пресеты с экспортом в JSON.','"For Telegram", "For YouTube", "For Discord (≤10 MB)", "For editing", "Lossless archive" and your own, exportable to JSON.')
# settings
k('settingsSearchHint','Поиск по настройкам','Search settings')
k('showAdvanced','{count, plural, one{Показать ещё {count} расширенную настройку} few{Показать ещё {count} расширенные настройки} many{Показать ещё {count} расширенных настроек} other{Показать ещё {count} расширенной настройки}}','{count, plural, one{Show {count} more advanced setting} other{Show {count} more advanced settings}}', count='int')
k('secGeneral','Общие','General'); k('secAppearance','Внешний вид','Appearance'); k('secPerformance','Производительность','Performance'); k('secPaths','Пути и папки','Paths & folders')
k('secDownloads','Загрузки (yt-dlp)','Downloads (yt-dlp)'); k('secUpdates','Компоненты и обновления','Components & updates'); k('secNotifications','Уведомления','Notifications'); k('secExpert','Для экспертов','For experts')
k('setLanguage','Язык интерфейса','Interface language'); k('setLanguageHint','По умолчанию — как в системе','Follows the system by default'); k('languageSystem','Как в системе','System')
k('setAdvancedMode','Расширенный режим','Advanced mode'); k('setAdvancedModeHint','Показывать все параметры, а не только главные','Show every option, not only the main ones')
k('setAdvancedModeHelp','В простом режиме у инструментов и в настройках видны только параметры, которые нужны в 90% случаев; остальные берут разумные значения по умолчанию. Расширенный режим открывает всё: профили и уровни кодеков, пиксельные форматы, число потоков и т. п. Поиск находит расширенные настройки в любом режиме. По умолчанию: выключен.','Simple mode shows only the options needed 90% of the time; the rest use sensible defaults. Advanced mode reveals everything: codec profiles and levels, pixel formats, thread counts and so on. Search finds advanced settings in either mode. Default: off.')
k('setTheme','Тема','Theme'); k('setThemeHint','Светлая, тёмная или как в системе','Light, dark or follow the system')
k('themeSystem','Системная','System'); k('themeLight','Светлая','Light'); k('themeDark','Тёмная','Dark')
k('setAccent','Акцентный цвет','Accent color'); k('setAccentHint','Цвет кнопок и выделений','Color of buttons and highlights')
k('setAccentHelp','«Системный» берёт акцент из настроек Windows или GNOME/KDE (Material You). Если система цвет не сообщает, используется выбранный ниже. По умолчанию: системный.','"System" takes the accent from Windows or GNOME/KDE settings (Material You). If the system provides none, the color picked below is used. Default: system.')
k('accentSystem','Системный','System'); k('accentCustom','Свой','Custom')
k('setParallel','Параллельные задачи','Parallel jobs'); k('setParallelHint','Сколько задач очереди выполнять одновременно','How many queue jobs run at the same time')
k('setParallelHelp','ffmpeg и так использует все ядра процессора, поэтому для перекодирования обычно лучше 1–2 задачи: каждая закончится быстрее. Больше задач выгодно для лёгких операций (ремукс, обрезка без перекодирования, загрузки) и при аппаратном кодировании, где видеокарта может вести несколько потоков. Рекомендуется: 1–2. По умолчанию: 1.','ffmpeg already uses all CPU cores, so 1–2 jobs is usually best for re-encoding: each finishes sooner. More jobs help with light work (remux, lossless trim, downloads) and with hardware encoding, where the GPU can handle several streams. Recommended: 1–2. Default: 1.')
k('zoneFasterEach','каждая быстрее','each one faster'); k('zoneMoreAtOnce','больше сразу','more at once')
k('setHwAccel','Аппаратное ускорение','Hardware acceleration'); k('setHwAccelHint','Кодировать на видеокарте, если она найдена','Encode on the GPU when one is found')
k('setHwAccelHelp','NVENC (NVIDIA), Quick Sync (Intel), AMF (AMD), VAAPI и Vulkan кодируют в разы быстрее процессора, но при том же размере файла качество немного ниже. Для архива и максимального качества выключите. Что именно найдено, видно в «Компонентах». По умолчанию: включено.','NVENC (NVIDIA), Quick Sync (Intel), AMF (AMD), VAAPI and Vulkan encode many times faster than the CPU, but quality per file size is slightly lower. Turn off for archiving and maximum quality. What was found is shown in Components. Default: on.')
k('setRetries','Повторы при ошибке','Retries on failure'); k('setRetriesHint','Сколько раз перезапускать упавшую задачу','How many times to restart a failed job')
k('setRetriesHelp','Полезно для загрузок и сетевых источников, где сбои бывают временными. Для локальных файлов ошибка обычно повторяется, поэтому по умолчанию: 0.','Useful for downloads and network sources where failures are often temporary. Local file errors usually repeat, so the default is 0.')
k('setThreads','Потоки ffmpeg','ffmpeg threads'); k('setThreadsHint','Ограничить число потоков процессора на задачу','Limit CPU threads per job')
k('setThreadsHelp','«авто» позволяет ffmpeg самому выбрать оптимум. Ограничение нужно, если вы хотите оставить процессор свободным для других программ во время кодирования. По умолчанию: авто.','"auto" lets ffmpeg choose. Set a limit to keep the CPU free for other apps while encoding. Default: auto.')
k('setOutputDir','Папка для результатов','Output folder'); k('setOutputDirHint','Куда сохранять готовые файлы','Where finished files go')
k('setOutputDirHelp','Если не задана, результаты сохраняются в папку «Kadra» внутри «Видео» (или домашней папки). Каждый инструмент также позволяет выбрать место вручную.','If not set, results go to a "Kadra" folder in Videos (or your home folder). Each tool also lets you choose a location manually.')
k('outputDirDefault','По умолчанию: {path}','Default: {path}', path='String')
k('setCustomFfmpeg','Свой ffmpeg','Custom ffmpeg'); k('setCustomFfmpegHint','Путь к уже установленному ffmpeg','Path to an existing ffmpeg')
k('setCustomFfmpegHelp','Имеет приоритет над загруженным компонентом и системным PATH. ffprobe ищется рядом автоматически. Полезно, если у вас своя сборка с нестандартными библиотеками.','Takes priority over the downloaded component and system PATH. ffprobe is looked up next to it. Useful for custom builds with extra libraries.')
k('setCustomFfprobe','Свой ffprobe','Custom ffprobe'); k('setCustomFfprobeHint','Если он лежит не рядом с ffmpeg','If it is not next to ffmpeg')
k('setCustomYtdlp','Свой yt-dlp','Custom yt-dlp'); k('setCustomYtdlpHint','Путь к уже установленному yt-dlp','Path to an existing yt-dlp')
k('setFragments','Параллельные фрагменты','Concurrent fragments'); k('setFragmentsHint','Сколько частей видео качать одновременно','How many video fragments to download at once')
k('setFragmentsHelp','yt-dlp --concurrent-fragments. Ускоряет загрузку потоковых форматов (DASH/HLS) с YouTube и других сайтов. Слишком большое значение может привести к временной блокировке со стороны сайта. Рекомендуется: 4–8. По умолчанию: 4.','yt-dlp --concurrent-fragments. Speeds up streaming formats (DASH/HLS) from YouTube and others. Too high may get you temporarily throttled. Recommended: 4–8. Default: 4.')
k('zoneGentle','бережнее к сайту','gentler on the site'); k('zoneFaster','быстрее','faster')
k('setPolicyFfmpeg','Обновления ffmpeg','ffmpeg updates'); k('setPolicyHint','Что делать, когда вышла новая версия','What to do when a new version is out')
k('setPolicyYtdlp','Обновления yt-dlp','yt-dlp updates'); k('setPolicyYtdlpHint','Сайты часто меняются — лучше обновлять автоматически','Sites change often, so automatic is best')
k('setPolicyOther','Обновления остальных компонентов','Other component updates')
k('setPolicyHelp','«Автоматически» — проверить и установить при запуске; «Спрашивать» — показать значок обновления в «Компонентах»; «Никогда» — не проверять. Предыдущая версия сохраняется, к ней можно откатиться. По умолчанию: yt-dlp — автоматически, остальное — спрашивать.','"Automatic" checks and installs at startup; "Ask" shows an update badge in Components; "Never" does not check. The previous version is kept so you can roll back. Default: yt-dlp automatic, others ask.')
k('policyAuto','Автоматически','Automatic'); k('policyAsk','Спрашивать','Ask'); k('policyNever','Никогда','Never')
k('setKeepVersions','Хранить предыдущие версии','Keep previous versions'); k('setKeepVersionsHint','Сколько старых версий оставить для отката','How many old versions to keep for rollback')
k('setKeepVersionsHelp','Каждая версия ffmpeg занимает 100–250 МБ. 0 — откат будет невозможен. По умолчанию: 2.','Each ffmpeg version takes 100–250 MB. 0 disables rollback. Default: 2.')
k('zoneLessDisk','меньше места','less disk'); k('zoneMoreRollback','больше откатов','more rollback')
k('setNotify','Уведомлять о завершении','Notify when done'); k('setNotifyHint','Системное уведомление, когда задача готова','A system notification when a job finishes')
k('setShowCommand','Показывать команду перед запуском','Show command before running'); k('setShowCommandHint','Можно проверить и отредактировать команду ffmpeg','Review and edit the ffmpeg command')
k('setShowCommandHelp','Перед добавлением в очередь откроется готовая команда ffmpeg: её можно скопировать, изменить и запустить. Кнопка «Показать команду» доступна у каждой задачи в любом случае. По умолчанию: выключено.','Before queueing, the generated ffmpeg command opens so you can copy, edit and run it. "Show command" is available on every job regardless. Default: off.')

# ---------------- stage 2
k('back','Назад','Back'); k('change','Изменить','Change'); k('apply','Применить','Apply'); k('rename','Переименовать','Rename'); k('save','Сохранить','Save')
k('none','нет','none'); k('keepOriginal','Как в исходнике','Keep original'); k('stereo','Стерео','Stereo'); k('mono','Моно','Mono'); k('toEnd','до конца','to the end')
k('addToQueue','В очередь','Add to queue'); k('runNow','Запустить','Run now'); k('otherFile','Другой файл','Other file')
k('saveTo','Сохранить в: {path}','Save to: {path}', path='String')
k('chooseInputTitle','Выберите файл','Choose a file')
k('commandEditHint','Можно изменить аргументы перед запуском (путь к ffmpeg подставится сам).','You can edit the arguments before running (the ffmpeg path is added automatically).')
k('commandParseError','Незакрытая кавычка в команде','Unterminated quote in the command'); k('runCommand','Запустить','Run')
k('stepLabel','шаг {step}','step {step}', step='String')
k('secondsShort','{value} с','{value} s', value='String')
# estimates/issues
k('estimateSize','≈ {size}','≈ {size}', size='String')
k('estimateAtMost','не больше {size}','at most {size}', size='String')
k('estimateDependsOnContent','Размер зависит от содержимого','Size depends on the content')
k('encoderLabel','кодировщик {name}','encoder {name}', name='String')
k('issueNoEncoder','В установленной сборке ffmpeg нет кодировщика для этого кодека. Выберите другой кодек или установите full-сборку.','The installed ffmpeg build has no encoder for this codec. Pick another codec or install a full build.')
k('issueVideoContainer','Этот контейнер не поддерживает выбранный видеокодек. Выберите другой кодек или MKV.','This container does not support the selected video codec. Pick another codec or MKV.')
k('issueAudioContainer','Этот контейнер не поддерживает выбранный аудиокодек. Выберите другой кодек или MKV.','This container does not support the selected audio codec. Pick another codec or MKV.')
k('issueCopyContainer','Исходный кодек нельзя скопировать в этот контейнер без перекодирования. Попробуйте MKV.','The source codec cannot be copied into this container. Try MKV.')
k('issueDurationUnknown','Длительность файла неизвестна, поэтому нельзя рассчитать размер или обрезку.','The file duration is unknown, so size or trim cannot be calculated.')
k('issueTargetTooSmall','Слишком маленький размер для такой длительности: на видео остаётся меньше 50 кбит/с. Увеличьте размер или уменьшите длительность.','The size is too small for this duration: less than 50 kb/s would remain for video. Increase the size or shorten the video.')
k('issueNoTenBit','Этот кодировщик не умеет 10 бит — будет 8 бит.','This encoder cannot do 10-bit; 8-bit will be used.')
k('issueNoAudio','В файле нет звуковой дорожки.','The file has no audio track.')
k('issueNoVideo','В файле нет видео.','The file has no video.')
k('issueChooseAudio','Выберите файл со звуком.','Choose an audio file.')
k('warnHdrSource','Исходник в HDR. Без 10 бит и тонмаппинга цвета будут блёклыми; полноценное HDR → SDR — в следующем этапе.','The source is HDR. Without 10-bit and tone mapping colors will look washed out; proper HDR → SDR comes in the next stage.')
k('warnLongGif','GIF длиннее 20 секунд получится очень большим. Лучше WebP или видео.','A GIF longer than 20 seconds will be huge. WebP or video is better.')
# groups
k('groupFormat','Формат','Format'); k('groupVideo','Видео','Video'); k('groupAudio','Звук','Audio'); k('groupOther','Прочее','Other')
k('groupTrim','Фрагмент','Fragment'); k('groupLoudness','Громкость','Loudness'); k('groupAnimation','Анимация','Animation')
k('groupDownloadQuality','Качество','Quality'); k('groupDownloadExtras','Дополнительно','Extras')
# presets
k('presetsTitle','Пресеты','Presets'); k('savePreset','Сохранить как пресет','Save as preset'); k('presetNameLabel','Название пресета','Preset name')
k('builtinPresets','Встроенные','Built-in'); k('userPresets','Мои пресеты','My presets')
k('userPresetsEmpty','Пока пусто. В «Конвертации» настройте параметры и нажмите «Сохранить как пресет».','Nothing yet. Set up Convert and press "Save as preset".')
k('importPresets','Импорт','Import'); k('exportPresets','Экспорт','Export')
k('presetsImported','{count, plural, one{Импортирован {count} пресет} few{Импортировано {count} пресета} many{Импортировано {count} пресетов} other{Импортировано {count} пресета}}','{count, plural, one{Imported {count} preset} other{Imported {count} presets}}', count='int')
k('presetsExported','{count, plural, one{Экспортирован {count} пресет} few{Экспортировано {count} пресета} many{Экспортировано {count} пресетов} other{Экспортировано {count} пресета}}','{count, plural, one{Exported {count} preset} other{Exported {count} presets}}', count='int')
k('presetsImportFailed','Это не файл пресетов Kadra.','This is not a Kadra presets file.')
k('presetTelegram','Для Telegram','For Telegram'); k('presetTelegramDesc','H.264 до 1080p, быстрый старт — проигрывается прямо в чате.','H.264 up to 1080p with fast start; plays right in the chat.')
k('presetYoutube','Для YouTube','For YouTube'); k('presetYoutubeDesc','Высокое качество (CRF 18), AAC 320 кбит/с 48 кГц — YouTube всё равно перекодирует.','High quality (CRF 18), AAC 320 kb/s 48 kHz; YouTube re-encodes anyway.')
k('presetDiscord','Для Discord (до 10 МБ)','For Discord (≤10 MB)'); k('presetDiscordDesc','Два прохода под 9,5 МБ, до 720p — влезает в бесплатный лимит.','Two-pass to 9.5 MB, up to 720p; fits the free limit.')
k('presetEditProres','Для монтажа (ProRes)','For editing (ProRes)'); k('presetEditProresDesc','ProRes 422 HQ + PCM: легко монтировать, файлы большие.','ProRes 422 HQ + PCM: easy to edit, large files.')
k('presetEditDnxhr','Для монтажа (DNxHR)','For editing (DNxHR)'); k('presetEditDnxhrDesc','DNxHR HQ + PCM для Avid и DaVinci Resolve.','DNxHR HQ + PCM for Avid and DaVinci Resolve.')
k('presetArchive','Архив без потерь','Lossless archive'); k('presetArchiveDesc','FFV1 + FLAC в MKV: бит в бит, без потери качества.','FFV1 + FLAC in MKV: bit-exact, no quality loss.')
k('presetMaxCompression','Максимальное сжатие','Maximum compression'); k('presetMaxCompressionDesc','AV1 10 бит + Opus: минимальный размер при хорошем качестве, но кодирует долго.','AV1 10-bit + Opus: smallest files at good quality, but slow to encode.')
k('presetCompress','Просто сжать','Just compress'); k('presetCompressDesc','H.264, качество чуть ниже, до 1080p — обычно в 2–5 раз меньше.','H.264, slightly lower quality, up to 1080p; usually 2–5× smaller.')
# codecs
k('codecCopy','Копировать (без перекодирования)','Copy (no re-encode)'); k('codecNoVideo','Без видео','No video'); k('codecNoAudio','Без звука','No audio')
k('codecFfv1','FFV1 (без потерь)','FFV1 (lossless)'); k('codecFlac','FLAC (без потерь)','FLAC (lossless)'); k('codecAlac','ALAC (без потерь)','ALAC (lossless)')
k('speedFastest','очень быстро','fastest'); k('speedFast','быстро','fast'); k('speedMedium','средне','medium'); k('speedSlow','медленно','slow'); k('speedSlowest','очень медленно','slowest')
k('rateQuality','Качество','Quality'); k('rateBitrate','Битрейт','Bitrate'); k('rateCbr','Постоянный','Constant'); k('rateTargetSize','Размер файла','File size')
k('zoneBetterQuality','лучше качество','better quality'); k('zoneSmallerFile','меньше размер','smaller file'); k('zoneSmoother','плавнее','smoother')
# convert params
k('pContainer','Контейнер (формат файла)','Container (file format)'); k('pContainerHint','Во что «упаковать» видео и звук','What wraps the video and audio')
k('pContainerHelp','Контейнер — это «коробка», в которой лежат дорожки. MP4 открывается везде (телефоны, браузеры, мессенджеры). MKV принимает почти любые кодеки и субтитры — хорош для архива. MOV — для Apple и монтажа. WebM — для сайтов (VP9/AV1 + Opus). Для одного звука: MP3, M4A, Opus, FLAC, WAV. По умолчанию: MP4.','The container is the "box" holding the tracks. MP4 plays everywhere (phones, browsers, messengers). MKV accepts almost any codec and subtitles; good for archiving. MOV is for Apple and editing. WebM is for the web (VP9/AV1 + Opus). Audio only: MP3, M4A, Opus, FLAC, WAV. Default: MP4.')
k('pVideoCodec','Видеокодек','Video codec'); k('pVideoCodecHint','Чем сжимать картинку','How the picture is compressed')
k('pVideoCodecHelp','H.264 — максимальная совместимость. H.265 — на 30–50% меньше при том же качестве, но не везде играет. AV1 — ещё меньше, кодирует медленнее (быстро на новых видеокартах). VP9 — для WebM. ProRes и DNxHR — для монтажа (большие файлы). FFV1 — без потерь. «Копировать» — мгновенно, без потери качества, если формат подходит. По умолчанию: H.264.','H.264: maximum compatibility. H.265: 30–50% smaller at the same quality but not supported everywhere. AV1: smaller still, slower to encode (fast on new GPUs). VP9: for WebM. ProRes and DNxHR: for editing (large files). FFV1: lossless. "Copy": instant and lossless if the container fits. Default: H.264.')
k('pAudioCodec','Аудиокодек','Audio codec'); k('pAudioCodecHint','Чем сжимать звук','How the audio is compressed')
k('pHardware','Аппаратное кодирование','Hardware encoding')
k('pHardwareOn','Используется видеокарта: {name}','Using the GPU: {name}', name='String')
k('pHardwareOff','Кодирует процессор: {name}','Encoding on the CPU: {name}', name='String')
k('pHardwareHelp','Видеокарта (NVENC, Quick Sync, AMF, VAAPI) кодирует в 5–20 раз быстрее процессора, но при том же размере файла качество немного ниже. Для быстрых задач — включите, для архива и минимального размера — выключите. Если подходящей видеокарты нет, используется процессор. По умолчанию: включено.','The GPU (NVENC, Quick Sync, AMF, VAAPI) encodes 5–20× faster than the CPU, but quality per file size is slightly lower. Turn on for quick jobs, off for archiving and smallest size. Without a suitable GPU the CPU is used. Default: on.')
k('pEncoder','Кодировщик','Encoder'); k('pEncoderHint','Конкретная реализация кодека из сборки ffmpeg','A specific implementation from the ffmpeg build')
k('pRateMode','Режим','Mode'); k('pRateModeHint','Как управлять размером и качеством','How size and quality are controlled')
k('pRateModeHelp','«Качество» (CRF/CQ) — лучший выбор почти всегда: постоянное качество, размер подстраивается под сложность сцены. «Битрейт» — средний поток в кбит/с, предсказуемый размер. «Постоянный» — одинаковый поток для стриминга и старых плееров. «Размер файла» — укажите, сколько мегабайт должно получиться (например, лимит мессенджера), битрейт рассчитается сам, по возможности в два прохода. По умолчанию: «Качество».','"Quality" (CRF/CQ) is nearly always best: constant quality, size adapts to scene complexity. "Bitrate": average kb/s, predictable size. "Constant": the same rate throughout, for streaming and old players. "File size": enter the megabytes you need (e.g. a messenger limit); bitrate is computed, two-pass when possible. Default: Quality.')
k('pQuality','Качество ({scale})','Quality ({scale})', scale='String'); k('pQualityHint','Меньше число — лучше качество и больше файл','Lower number: better quality, bigger file')
k('pQualityHelp','Это «постоянное качество» кодировщика: каждая сцена кодируется так, чтобы выглядеть одинаково хорошо. Шаг в 6 единиц примерно вдвое меняет размер. Для x264: 18 — визуально без потерь, 23 — стандарт, 28 — заметно хуже. У AV1/VP9 шкала до 63. Значение по умолчанию для этого кодировщика: {value}.','This is the encoder\'s "constant quality": every scene is encoded to look equally good. A change of 6 roughly doubles or halves the size. For x264: 18 is visually lossless, 23 is standard, 28 is noticeably worse. AV1/VP9 use a scale up to 63. Default for this encoder: {value}.', value='int')
k('pVideoBitrate','Битрейт видео','Video bitrate'); k('pVideoBitrateHint','Сколько килобит в секунду на видео','Kilobits per second for video')
k('pVideoBitrateHelp','Ориентиры для H.264: 1080p — 4000–8000, 720p — 2500–5000, 480p — 1000–2000 кбит/с. H.265/AV1 нужно примерно на 30–50% меньше.','H.264 guide: 1080p 4000–8000, 720p 2500–5000, 480p 1000–2000 kb/s. H.265/AV1 need about 30–50% less.')
k('pTargetSize','Размер файла','File size'); k('pTargetSizeHint','Итоговый файл будет не больше этого','The result will not exceed this')
k('pTargetSizeHelp','Битрейт рассчитывается из длительности: (размер × 8) / секунды − звук, с запасом 3% на контейнер. Слишком маленький размер для длинного видео даст «мыло» — уменьшите разрешение. Discord: 10 МБ (ставьте 9,5), Telegram для ботов: 50 МБ.','The bitrate is computed from duration: (size × 8) / seconds − audio, with 3% headroom for the container. Too small a size for a long video looks blurry; lower the resolution. Discord: 10 MB (use 9.5), Telegram bots: 50 MB.')
k('pTwoPass','Два прохода','Two-pass'); k('pTwoPassHint','Точнее попадает в размер, но вдвое дольше','Hits the size more precisely, takes twice as long')
k('pTwoPassHelp','Первый проход анализирует видео, второй распределяет биты: сложным сценам больше, простым меньше. Даёт лучшее качество при заданном размере. Для режима «Качество» не нужен. По умолчанию: включено.','The first pass analyzes the video, the second distributes bits: more to complex scenes, less to simple ones. Best quality at a given size. Not needed in Quality mode. Default: on.')
k('pSpeed','Скорость кодирования','Encoding speed'); k('pSpeedHint','Медленнее — меньше файл при том же качестве','Slower: smaller file at the same quality')
k('pSpeedHelp','Пресет скорости кодировщика (x264: veryfast…veryslow, NVENC: p1…p7, SVT-AV1: 12…4). Качество задаётся отдельно; медленный пресет лишь лучше сжимает. «Средне» — разумный баланс; «медленно» даёт −5–10% размера за ×2–3 времени. По умолчанию: средне.','The encoder speed preset (x264 veryfast…veryslow, NVENC p1…p7, SVT-AV1 12…4). Quality is set separately; a slower preset just compresses better. "Medium" is a good balance; "slow" saves 5–10% for 2–3× the time. Default: medium.')
k('pResolution','Разрешение','Resolution'); k('pResolutionHint','Уменьшить до этой высоты (не увеличивает)','Downscale to this height (never upscales)')
k('pResolutionHelp','Пропорции сохраняются, ширина округляется до чётной. Уменьшение разрешения — самый эффективный способ сжать: 1080p → 720p уменьшает файл примерно вдвое. По умолчанию: как в исходнике.','The aspect ratio is kept and the width rounded to even. Lowering the resolution is the most effective way to shrink: 1080p → 720p roughly halves the file. Default: keep original.')
k('pFps','Частота кадров','Frame rate'); k('pFpsHint','Кадров в секунду','Frames per second')
k('pTenBit','10 бит','10-bit'); k('pTenBitHint','Меньше полос на градиентах, нужно для HDR','Less banding on gradients, needed for HDR')
k('pTenBitHelp','10 бит на канал убирают «ступеньки» на небе и в тенях и немного улучшают сжатие у H.265/AV1. Старые устройства и некоторые браузеры H.264 10 бит не воспроизводят. По умолчанию: выключено.','10 bits per channel remove banding in skies and shadows and slightly improve H.265/AV1 compression. Old devices and some browsers cannot play 10-bit H.264. Default: off.')
k('pProfile','Профиль','Profile'); k('pProfileHint','Ограничения совместимости кодека','Codec compatibility constraints')
k('pIntermediateProfileHint','Качество и размер монтажного формата','Quality and size of the editing format')
k('pIntermediateProfileHelp','ProRes: proxy < lt < standard < hq < 4444 < 4444xq. DNxHR: lb < sq < hq < hqx (10 бит) < 444. Для монтажа обычно хватает HQ. По умолчанию: HQ.','ProRes: proxy < lt < standard < hq < 4444 < 4444xq. DNxHR: lb < sq < hq < hqx (10-bit) < 444. HQ is usually enough for editing. Default: HQ.')
k('pTune','Настройка под содержимое','Tune'); k('pTuneHint','Оптимизация под тип видео','Optimize for the type of content')
k('pTuneHelp','film — живое видео, animation — мультфильмы, grain — сохранить зерно плёнки, stillimage — слайд-шоу, zerolatency — стриминг с минимальной задержкой. По умолчанию: нет.','film: live action, animation: cartoons, grain: keep film grain, stillimage: slideshows, zerolatency: low-latency streaming. Default: none.')
k('pKeyint','Интервал ключевых кадров','Keyframe interval'); k('pKeyintHint','Как часто можно начать воспроизведение с любого места','How often playback can start from any point')
k('pKeyintHelp','Чем чаще ключевые кадры, тем быстрее перемотка и точнее быстрая обрезка, но файл больше. Для YouTube и стриминга рекомендуют 2 секунды. По умолчанию: авто (решает кодировщик).','More frequent keyframes mean faster seeking and more precise fast trims, but larger files. YouTube and streaming recommend 2 seconds. Default: auto (encoder decides).')
k('pAudioBitrate','Битрейт звука','Audio bitrate'); k('pAudioBitrateHint','Больше — лучше звук и больше файл','Higher: better sound, bigger file')
k('pAudioBitrateHelp','Ориентиры: AAC 128 — нормально для речи и музыки, 192–256 — для музыки, 320 — максимум. Opus звучит хорошо уже на 96. MP3 320 — предел формата. По умолчанию: зависит от кодека.','Guide: AAC 128 is fine for speech and music, 192–256 for music, 320 is the maximum. Opus already sounds good at 96. MP3 320 is the format limit. Default: depends on the codec.')
k('pChannels','Каналы','Channels'); k('pChannelsHint','Например, свести 5.1 в стерео','E.g. downmix 5.1 to stereo')
k('pSampleRate','Частота дискретизации','Sample rate'); k('pSampleRateHint','48 кГц — видео, 44,1 кГц — музыка','48 kHz for video, 44.1 kHz for music')
k('pFaststart','Быстрый старт (faststart)','Fast start'); k('pFaststartHint','Видео начинает играть в браузере до полной загрузки','Starts playing in a browser before fully downloaded')
k('pFaststartHelp','Переносит индекс (moov) в начало MP4/MOV. Нужен для сайтов и мессенджеров, ничего не стоит. По умолчанию: включено.','Moves the index (moov) to the start of MP4/MOV. Needed for websites and messengers, costs nothing. Default: on.')
k('pKeepSubs','Сохранить субтитры','Keep subtitles'); k('pKeepSubsHint','Скопировать дорожки субтитров как есть','Copy subtitle tracks as is')
k('pKeepMetadata','Сохранить метаданные','Keep metadata'); k('pKeepMetadataHint','Теги, главы, дата съёмки. Выключите, чтобы удалить','Tags, chapters, capture date. Turn off to strip them')
# trim
k('pTrimMode','Способ обрезки','Trim method'); k('trimFast','Быстро','Fast'); k('trimPrecise','Точно до кадра','Frame-accurate')
k('trimFastHint','Мгновенно, без потери качества; начало — по ближайшему ключевому кадру','Instant and lossless; starts at the nearest keyframe')
k('trimPreciseHint','Перекодирует фрагмент: точные границы, но дольше','Re-encodes: exact boundaries, takes longer')
k('pTrimModeHelp','Видео хранится группами кадров, которые начинаются с ключевого кадра. Быстрая обрезка копирует данные как есть, поэтому может начаться чуть раньше выбранной точки — до ближайшего ключевого кадра (обычно 0–5 секунд). Точная перекодирует фрагмент и режет ровно по кадру; качество почти не страдает.','Video is stored in groups of frames that start with a keyframe. Fast trimming copies data as is, so it may start slightly before your point, at the nearest keyframe (usually 0–5 s). Frame-accurate re-encodes the fragment and cuts exactly; quality is barely affected.')
k('pStart','Начало','Start'); k('pStartHint','ЧЧ:ММ:СС.мс или секунды','HH:MM:SS.ms or seconds')
k('pEnd','Конец','End'); k('pEndHint','Длительность файла: {total}','File duration: {total}', total='String')
k('keyframeStartHint','Фактически начнётся с {time} (ключевой кадр)','Will actually start at {time} (keyframe)', time='String')
k('setStartHere','Начало = {time}','Start = {time}', time='String'); k('setEndHere','Конец = {time}','End = {time}', time='String')
k('trimLength','Фрагмент: {time}','Fragment: {time}', time='String')
# audio
k('pTrack','Дорожка','Track'); k('pTrackHint','Какую звуковую дорожку извлечь','Which audio track to extract')
k('pExtractFormat','Формат','Format'); k('pExtractFormatHint','Перекодировать в выбранный формат','Re-encode to the chosen format')
k('pExtractFormatHelp','«Как есть» копирует звук без изменений — мгновенно и без потерь, формат файла подбирается под кодек. Выберите MP3/AAC/Opus, если нужен конкретный формат для плеера, FLAC/WAV — для обработки без потерь.','"As is" copies the audio unchanged: instant and lossless, the file type matches the codec. Choose MP3/AAC/Opus for a specific player format, FLAC/WAV for lossless editing.')
k('extractAsIs','Как есть (без перекодирования)','As is (no re-encode)')
k('extractCopyHint','Будет файл .{ext} без потери качества','You will get a lossless .{ext} file', ext='String')
k('pTrackMode','Что сделать','Action'); k('trackReplace','Заменить','Replace'); k('trackAdd','Добавить','Add'); k('trackRemove','Удалить звук','Remove audio')
k('trackReplaceHint','Убрать старый звук и поставить новый','Drop the old audio and use the new one')
k('trackAddHint','Оставить старые дорожки и добавить ещё одну (например, перевод)','Keep existing tracks and add another (e.g. a dub)')
k('trackRemoveHint','Сделать видео без звука','Make the video silent')
k('pAudioFile','Файл со звуком','Audio file'); k('pAudioFileHint','Можно взять звук из любого аудио- или видеофайла','Audio can come from any audio or video file')
k('pShortest','По самой короткой дорожке','Stop at the shortest track'); k('pShortestHint','Обрезать результат, когда кончится видео или звук','End the result when video or audio ends')
k('pLanguage','Язык дорожки','Track language'); k('pLanguageHint','Плееры покажут его при выборе дорожки','Players show it in the track menu')
k('losslessVideoTag','видео без перекодирования','video not re-encoded')
k('videoCopiedNote','Видео копируется — быстро и без потери качества','Video is copied: fast and lossless')
k('pLoudTarget','Целевая громкость','Target loudness')
k('pLoudTargetHint','{lufs} LUFS, пики не выше {tp} dBTP','{lufs} LUFS, peaks at most {tp} dBTP', lufs='String', tp='String')
k('pLoudTargetHelp','LUFS — воспринимаемая громкость. Площадки сами приглушают слишком громкое, поэтому лучше сразу попасть в их цель: YouTube и Spotify −14, подкасты (Apple) −16, ТВ по EBU R128 −23. True Peak ограничивает пики, чтобы не было искажений после сжатия в MP3/AAC.','LUFS is perceived loudness. Platforms turn down anything too loud, so it is best to hit their target: YouTube and Spotify −14, podcasts (Apple) −16, TV per EBU R128 −23. True Peak limits peaks so MP3/AAC compression does not distort.')
k('loudStreaming','YouTube, Spotify','YouTube, Spotify'); k('loudPodcast','Подкаст','Podcast'); k('loudBroadcast','ТВ (EBU R128)','TV (EBU R128)'); k('loudApple','Apple Music','Apple Music')
k('pTwoPassLoud','Двухпроходная нормализация','Two-pass normalization')
k('pTwoPassLoudOn','Сначала измерить, затем точно привести громкость','Measure first, then adjust precisely')
k('pTwoPassLoudOff','Один проход: быстрее, но с динамической подстройкой','One pass: faster, but adjusts dynamically')
k('pTwoPassLoudHelp','Первый проход измеряет громкость всего файла, второй применяет одно и то же усиление ко всему — динамика не меняется, результат точно в цели. Однопроходный режим подстраивает громкость на лету и может «качать» звук. По умолчанию: два прохода.','The first pass measures the whole file, the second applies one gain everywhere: dynamics are preserved and the result hits the target. One-pass mode adjusts on the fly and may pump. Default: two-pass.')
k('normalizeNote','Звук будет перекодирован ({codec}), видео скопировано','Audio will be re-encoded ({codec}), video copied', codec='String')
# gif
k('pAnimFormat','Формат','Format'); k('pAnimFormatHint','GIF работает везде, WebP и APNG — качественнее и меньше','GIF works everywhere; WebP and APNG look better and are smaller')
k('pAnimFormatHelp','GIF ограничен 256 цветами, поэтому для него строится оптимальная палитра под конкретное видео. WebP даёт полноцветную анимацию в 2–5 раз меньше. APNG — без потерь, но тяжёлый. По умолчанию: GIF.','GIF is limited to 256 colors, so an optimal palette is built for the clip. WebP gives full-color animation 2–5× smaller. APNG is lossless but heavy. Default: GIF.')
k('pDuration','Длительность','Duration'); k('pDurationHint','Пусто — до конца файла','Empty means to the end')
k('pGifFps','Кадров в секунду','Frames per second'); k('pGifFpsHint','10–15 обычно достаточно','10–15 is usually enough')
k('pGifWidth','Ширина','Width'); k('pGifWidthHint','Высота подберётся по пропорциям','Height follows the aspect ratio')
k('pDither','Дизеринг','Dithering'); k('pDitherHint','Как имитировать недостающие цвета','How missing colors are simulated')
k('pDitherHelp','Sierra — мягкий и аккуратный (по умолчанию). Floyd–Steinberg — больше деталей, больше «шума». Bayer — регулярный узор, хорошо сжимается. Без дизеринга — полосы на градиентах, но меньше файл.','Sierra: soft and clean (default). Floyd–Steinberg: more detail, more noise. Bayer: regular pattern, compresses well. None: banding on gradients but smaller files.')
k('pStaticBg','Статичный фон','Static background'); k('pStaticBgHint','Лучше цвета, если двигается только часть кадра','Better colors when only part of the frame moves')
k('pWebpQuality','Качество WebP','WebP quality'); k('pWebpQualityHint','75 — хороший баланс','75 is a good balance')
k('pLoop','Зациклить','Loop'); k('pLoopHint','Повторять анимацию бесконечно','Repeat the animation forever')
k('gifFrames','{count} кадров','{count} frames', count='int')
# downloads
k('urlsLabel','Ссылки','Links'); k('urlsHint','Вставьте одну или несколько ссылок (на видео, плейлист или канал)','Paste one or more links (video, playlist or channel)')
k('pasteFromClipboard','Вставить из буфера: {url}','Paste from clipboard: {url}', url='String')
k('analyzeLinks','Получить информацию','Get info'); k('downloadWithoutAnalysis','Скачать сразу','Download now')
k('download','Скачать','Download')
k('downloadN','Скачать ({count})','Download ({count})', count='int')
k('downloadsQueued','{count, plural, one{В очередь добавлена {count} загрузка} few{В очередь добавлено {count} загрузки} many{В очередь добавлено {count} загрузок} other{В очередь добавлено {count} загрузки}}','{count, plural, one{{count} download queued} other{{count} downloads queued}}', count='int')
k('downloadsNeedYtdlpTitle','Нужен yt-dlp','yt-dlp is required')
k('denoHint','Совет: для YouTube установите Deno в «Компонентах» — без него часть форматов недоступна.','Tip: install Deno in Components for YouTube; without it some formats are unavailable.')
k('selectedOf','Выбрано {selected} из {total}','{selected} of {total} selected', selected='int', total='int')
k('selectAll','Все','All'); k('selectNone','Ни одного','None'); k('rangesHint','Номера: 1,3,5-10','Numbers: 1,3,5-10')
k('availableQualities','Есть: {list}','Available: {list}', list='String')
k('exactFormat','Точный формат (необязательно)','Exact format (optional)'); k('exactFormatAuto','Автоматически по качеству ниже','Automatic from quality below')
k('videoOnly','только видео','video only')
k('pYtQuality','Качество','Quality'); k('pYtQualityHint','Лучшее доступное или не выше выбранного','Best available or at most the chosen height')
k('ytBest','Лучшее','Best'); k('ytUpTo','до {height}','up to {height}', height='String'); k('ytAudioOnly','Только звук','Audio only')
k('pYtAudioFormat','Формат звука','Audio format'); k('pYtAudioFormatHint','В какой формат сохранить звук','Format to save the audio in')
k('pYtContainerHint','MP4 — для совместимости, MKV — без ограничений','MP4 for compatibility, MKV without limits')
k('pYtContainerHelp','Сайты часто отдают видео и звук отдельно; yt-dlp склеивает их через ffmpeg в выбранный контейнер. Для MP4 предпочитаются H.264/AAC, чтобы не перекодировать. «Как на сайте» сохраняет исходный формат (часто WebM).','Sites often serve video and audio separately; yt-dlp merges them with ffmpeg into the chosen container. For MP4, H.264/AAC is preferred to avoid re-encoding. "As on the site" keeps the original format (often WebM).')
k('ytContainerAuto','Как на сайте','As on the site')
k('pYtSubs','Субтитры','Subtitles'); k('pYtSubsHint','Скачать и вшить субтитры авторов','Download and embed creator subtitles')
k('pYtAutoSubs','Автоматические субтитры','Automatic subtitles'); k('pYtAutoSubsHint','Сгенерированные сайтом (например, YouTube)','Generated by the site (e.g. YouTube)')
k('pYtSubLangs','Языки субтитров','Subtitle languages'); k('pYtSubLangsHint','Через запятую: ru,en или all','Comma-separated: ru,en or all')
k('pYtEmbed','Обложка, метаданные и главы','Cover, metadata and chapters'); k('pYtEmbedHint','Вшить в файл','Embed into the file')
k('pSponsorBlock','SponsorBlock','SponsorBlock'); k('pSponsorBlockHint','Рекламные вставки авторов','Creator sponsor segments')
k('pSponsorBlockHelp','Использует базу sponsor.ajay.app. «Отметить» добавляет главы, «Вырезать» удаляет спонсорские вставки, саморекламу и просьбы подписаться (требует перекодирования фрагментов).','Uses the sponsor.ajay.app database. "Mark" adds chapters; "Remove" cuts sponsor segments, self-promotion and subscribe reminders (re-encodes around cuts).')
k('sbOff','Не трогать','Off'); k('sbMark','Отметить главами','Mark as chapters'); k('sbRemove','Вырезать','Remove')
k('pCookies','Cookies из браузера','Browser cookies'); k('pCookiesHint','Для приватных, 18+ и «подтвердите, что вы не бот»','For private, age-restricted and "confirm you are not a bot"')
k('pCookiesHelp','yt-dlp прочитает cookies входа из выбранного браузера, как будто видео открыли в нём. Браузер лучше закрыть (Chrome блокирует файл cookies). Cookies никуда не отправляются, кроме самого сайта.','yt-dlp reads your login cookies from the chosen browser, as if the video were opened there. Close the browser first (Chrome locks its cookie file). Cookies go nowhere except to the site itself.')
k('pArchive','Не качать повторно','Skip already downloaded'); k('pArchiveHint','Вести список скачанного в папке загрузок','Keep a list of downloaded videos in the output folder')
k('pTemplate','Шаблон имени файла','File name template'); k('pTemplateHint','Поля yt-dlp: %(title)s, %(id)s, %(uploader)s…','yt-dlp fields: %(title)s, %(id)s, %(uploader)s…')
k('pTemplateHelp','Например: «%(uploader)s/%(title)s.%(ext)s» разложит видео по папкам каналов. Полный список полей — в документации yt-dlp (OUTPUT TEMPLATE).','E.g. "%(uploader)s/%(title)s.%(ext)s" sorts videos into channel folders. All fields are in the yt-dlp docs (OUTPUT TEMPLATE).')
k('pRateLimit','Ограничение скорости','Rate limit'); k('pRateLimitHint','Например 5M = 5 МБ/с; пусто — без ограничения','E.g. 5M = 5 MB/s; empty means unlimited')
k('pProxy','Прокси','Proxy'); k('pProxyHint','http://, https:// или socks5://','http://, https:// or socks5://')
# settings stage 2
k('setNextToSource','Сохранять рядом с исходным','Save next to the source'); k('setNextToSourceHint','Результат в той же папке, что и исходный файл','Put results in the same folder as the source file')
k('setAria2','Загрузка через aria2c','Download with aria2c'); k('setAria2Hint','Многопоточная загрузка, если aria2c установлен','Multi-connection downloads when aria2c is installed')
k('setAria2Help','aria2c открывает несколько соединений к серверу и часто качает быстрее на медленных серверах. Для YouTube обычно хватает встроенных параллельных фрагментов. По умолчанию: выключено.','aria2c opens several connections and is often faster with slow servers. For YouTube the built-in concurrent fragments are usually enough. Default: off.')

# ---------------- stage 3: audio editor
k('toolAudioEditor','Аудиоредактор','Audio editor')
k('toolAudioEditorDesc','Многодорожечный редактор: правка, эффекты, генераторы, анализ, запись.','Multitrack editor: editing, effects, generators, analysis, recording.')
k('cut','Вырезать','Cut'); k('paste','Вставить','Paste'); k('undo','Отменить','Undo'); k('redo','Повторить','Redo')
k('undoX','Отменить: {action}','Undo {action}', action='String'); k('redoX','Повторить: {action}','Redo {action}', action='String')
k('preview','Прослушать','Preview'); k('generate','Создать','Generate'); k('export','Экспорт','Export'); k('record','Запись','Record'); k('stop','Стоп','Stop')
k('mute','Заглушить','Mute'); k('solo','Соло','Solo'); k('moveUp','Выше','Move up'); k('moveDown','Ниже','Move down')
k('zoomIn','Приблизить (Ctrl+=)','Zoom in (Ctrl+=)'); k('zoomOut','Отдалить (Ctrl+−)','Zoom out (Ctrl+−)')
k('zoomSelection','По выделению (Ctrl+E)','Zoom to selection (Ctrl+E)'); k('zoomFit','Весь проект (Ctrl+F)','Fit project (Ctrl+F)')
k('unitDb','дБ','dB'); k('unitMs','мс','ms'); k('unitSemitones','полутонов','semitones'); k('unitBpm','уд/мин','BPM'); k('unitDbOct','дБ/окт','dB/oct')
k('menuFile','Файл','File'); k('menuEdit','Правка','Edit'); k('menuGenerate','Создать','Generate'); k('menuEffects','Эффекты','Effects'); k('menuAnalyze','Анализ','Analyze'); k('menuTracks','Дорожки','Tracks')
k('aeNew','Новый проект','New project'); k('aeOpenProject','Открыть проект…','Open project…'); k('aeSaveProject','Сохранить проект','Save project'); k('aeSaveProjectAs','Сохранить проект как…','Save project as…')
k('aeImport','Импорт аудио…','Import audio…'); k('aeImportLabels','Импорт меток…','Import labels…'); k('aeExportLabels','Экспорт меток…','Export labels…')
k('aeDelete','Удалить','Delete'); k('aeSilence','Заполнить тишиной','Silence audio'); k('aeTrim','Оставить только выделенное','Trim to selection')
k('aeDuplicate','Дублировать в новую дорожку','Duplicate to new track'); k('aeSplitNew','Отделить в новую дорожку','Split to new track')
k('aeCrossfade','Плавный переход в точке курсора','Crossfade at cursor'); k('aeSelectAll','Выделить всё','Select all')
k('aeNoiseProfile','Взять профиль шума из выделения','Get noise profile from selection')
k('addLabel','Добавить метку','Add label'); k('editLabel','Изменить метку','Edit label'); k('labelText','Текст метки','Label text')
k('labelHint','Клик — выделить, двойной клик — переименовать, правый клик — удалить','Click: select, double-click: rename, right-click: delete')
k('labelsTrack','Метки','Labels')
k('labelsAdded','{count, plural, one{Добавлена {count} метка} few{Добавлено {count} метки} many{Добавлено {count} меток} other{Добавлено {count} метки}}','{count, plural, one{{count} label added} other{{count} labels added}}', count='int')
k('aeAddTrack','Добавить дорожку из файла…','Add track from file…'); k('aeMixRender','Свести в новую дорожку','Mix and render to new track')
k('aeSplitStereo','Разделить стерео на моно','Split stereo to mono'); k('aeSpectrogramView','Показать спектрограмму','Show spectrogram'); k('aeWaveformView','Показать волну','Show waveform')
k('aeClearEnvelope','Сбросить огибающую','Clear envelope'); k('aeRemoveTrack','Удалить дорожку','Remove track'); k('trackName','Имя дорожки','Track name')
k('trackGain','Громкость дорожки','Track gain'); k('trackPan','Панорама','Pan')
k('aePlayHint','Воспроизвести / пауза (Пробел)','Play / pause (Space)'); k('aePlaySelection','Воспроизвести выделение (Shift+Пробел)','Play selection (Shift+Space)'); k('aeLoop','Повтор выделения','Loop selection')
k('toolSelect','Выделение','Selection tool'); k('toolShift','Сдвиг во времени','Time shift tool'); k('toolEnvelope','Огибающая громкости','Envelope tool')
k('aeCursorAt','Курсор: {time}','Cursor: {time}', time='String')
k('aeSelectionInfo','Выделение: {start} – {end} ({length})','Selection: {start} – {end} ({length})', start='String', end='String', length='String')
k('aeEmptyTitle','Аудиоредактор','Audio editor')
k('aeEmptyBody','Перетащите сюда аудио или видео, откройте проект или начните запись с микрофона.','Drop audio or video here, open a project or start recording.')
k('aeNeedSelection','Сначала выделите фрагмент.','Select a region first.')
k('aeStatusHint','Перетаскивайте по волне, чтобы выделить; Ctrl+колесо — масштаб, Shift+колесо — прокрутка; клик по имени дорожки — выбрать её.','Drag on the waveform to select; Ctrl+wheel zooms, Shift+wheel scrolls; click a track name to select it.')
k('applyToSelection','{count, plural, one{Применится к выделению на {count} дорожке} other{Применится к выделению на {count} дорожках}}','{count, plural, one{Applies to the selection on {count} track} other{Applies to the selection on {count} tracks}}', count='int')
k('applyToWholeTracks','{count, plural, one{Выделения нет — применится ко всей дорожке} other{Выделения нет — применится к {count} дорожкам целиком}}','{count, plural, one{No selection: applies to the whole track} other{No selection: applies to {count} whole tracks}}', count='int')
k('fxBrokenInBuild','Этот фильтр аварийно завершается в установленной сборке ffmpeg. Выберите другую сборку или откатитесь в «Компонентах».','This filter crashes in the installed ffmpeg build. Choose another build or roll back in Components.')
k('fxStereoOnly','Эффект работает только со стерео — моно-дорожки будут пропущены.','This effect needs stereo; mono tracks are skipped.')
k('fxDartDsp','Этого эффекта нет в ffmpeg, он выполняется встроенным обработчиком Kadra.','ffmpeg has no such effect; Kadra processes it with its own DSP.')
k('useNoiseProfile','Использовать профиль шума','Use the noise profile')
k('noNoiseProfile','Профиля нет: выделите участок, где только шум, и выберите «Правка → Взять профиль шума».','No profile: select a noise-only part and choose Edit → Get noise profile.')
k('noiseProfileReady','Профиль шума: {seconds} с','Noise profile: {seconds} s', seconds='String'); k('noiseProfileShort','профиль шума','noise profile')
k('controlTrack','Управляющая дорожка (голос)','Control track (voice)'); k('chooseTrack','Выберите дорожку','Choose a track')
k('flatten','Сбросить в ноль','Flatten')
k('generateReplaces','Есть выделение — оно будет заменено сгенерированным звуком.','The selection will be replaced with the generated audio.')
k('generateInserts','Звук будет вставлен в позицию курсора.','The audio will be inserted at the cursor.')
k('dtmfDigits','Цифры и символы (0–9, *, #, A–D)','Digits and symbols (0–9, *, #, A–D)')
k('anStats','Статистика и громкость','Statistics and loudness'); k('anSpectrum','Спектр частот','Plot spectrum')
k('anSounds','Найти звуки','Label sounds'); k('anSilence','Найти тишину','Find silence'); k('anBeats','Найти сильные доли','Beat finder'); k('anClipping','Найти перегрузку (клиппинг)','Find clipping')
k('findAndLabel','Найти и отметить','Find and label')
k('channelN','Канал {n}','Channel {n}', n='int')
k('statPeak','Пиковый уровень','Peak'); k('statRms','Средний уровень (RMS)','RMS'); k('statDc','Смещение постоянной составляющей','DC offset'); k('statClipped','Сэмплов в перегрузке','Clipped samples')
k('statIntegrated','Интегральная громкость','Integrated loudness'); k('statLra','Диапазон громкости','Loudness range'); k('statTruePeak','Истинный пик','True peak')
k('exportAudio','Экспорт аудио…','Export audio…'); k('exportAll','Весь проект','Whole project'); k('exportSelection','Выделение','Selection'); k('exportByLabels','По меткам (несколько файлов)','By labels (multiple files)')
k('aeExportSelection','Экспорт выделения…','Export selection…'); k('aeExportByLabels','Экспорт по меткам…','Export by labels…')
k('metadataTitle','Метаданные','Metadata'); k('metaTitle','Название','Title'); k('metaArtist','Исполнитель','Artist'); k('metaAlbum','Альбом','Album'); k('metaYear','Год','Year'); k('metaGenre','Жанр','Genre'); k('metaTrack','Номер трека','Track number'); k('metaComment','Комментарий','Comment')
k('recordTitle','Запись','Recording'); k('noRecordingDevices','Устройства записи не найдены.','No recording devices found.')
k('recordHint','Запись появится новой дорожкой с позиции курсора.','The recording becomes a new track at the cursor.')
k('histImport','импорт','import'); k('histDelete','удаление','delete'); k('histSilence','тишина','silence'); k('histTrim','обрезка','trim'); k('histPaste','вставка','paste')
k('histDuplicate','дублирование','duplicate'); k('histSplitNew','отделение','split to new track'); k('histCrossfade','плавный переход','crossfade'); k('histRemoveTrack','удаление дорожки','remove track')
k('histMoveTrack','перемещение дорожки','move track'); k('histMixRender','сведение','mix and render'); k('histSplitStereo','разделение стерео','split stereo'); k('histLabels','метки','labels'); k('histRecord','запись','recording'); k('histTrack','изменение дорожки','track change')
# categories
k('fxcVolume','Громкость и динамика','Volume and compression'); k('fxcFades','Затухания','Fading'); k('fxcEq','Эквалайзер и фильтры','EQ and filters'); k('fxcNoise','Шум и ремонт','Noise removal and repair')
k('fxcPitchTempo','Высота и темп','Pitch and tempo'); k('fxcDelayReverb','Задержка и реверберация','Delay and reverb'); k('fxcDistortion','Искажение и модуляция','Distortion and modulation'); k('fxcSpecial','Специальные','Special')
fx = [
 ('Amplify','Усиление','Amplify','Делает звук громче или тише на заданное число децибел.','Makes the audio louder or quieter by a number of decibels.'),
 ('Normalize','Нормализация пика','Normalize','Поднимает уровень так, чтобы пик достиг заданного значения; может убрать смещение DC.','Raises the level so the peak hits the target; can remove DC offset.'),
 ('Loudness','Нормализация громкости (LUFS)','Loudness normalization','Приводит воспринимаемую громкость к цели по EBU R128 (два прохода).','Brings perceived loudness to an EBU R128 target (two passes).'),
 ('Compressor','Компрессор','Compressor','Уменьшает разницу между громкими и тихими местами.','Reduces the difference between loud and quiet parts.'),
 ('Limiter','Лимитер','Limiter','Не даёт пикам превысить заданный уровень.','Keeps peaks below a ceiling.'),
 ('Gate','Шумовой гейт','Noise gate','Приглушает звук, когда он тише порога (паузы между фразами).','Mutes audio below a threshold (pauses between phrases).'),
 ('AutoDuck','Автоприглушение','Auto duck','Приглушает музыку, когда звучит голос на другой дорожке.','Lowers music while the voice on another track plays.'),
 ('DynamicNormalizer','Динамический нормализатор','Dynamic normalizer','Выравнивает громкость по ходу записи, не трогая короткую динамику.','Evens out loudness over time while keeping short-term dynamics.'),
 ('SpeechNormalizer','Нормализатор речи','Speech normalizer','Выравнивает громкость речи: тихие фразы громче, громкие тише.','Evens out speech: quiet phrases louder, loud ones quieter.'),
 ('FadeIn','Плавное нарастание','Fade in',None,None),
 ('FadeOut','Плавное затухание','Fade out',None,None),
 ('StudioFadeOut','Студийное затухание','Studio fade out',None,None),
 ('AdjustableFade','Настраиваемое затухание','Adjustable fade','Меняет громкость от одного процента до другого по выделению.','Changes volume from one percentage to another across the selection.'),
 ('BassTreble','Басы и высокие','Bass and treble','Поднимает или срезает низкие и высокие частоты.','Boosts or cuts low and high frequencies.'),
 ('GraphicEq','Графический эквалайзер','Graphic EQ','18 полос от 65 Гц до 20 кГц.','18 bands from 65 Hz to 20 kHz.'),
 ('ParametricEq','Параметрический эквалайзер','Parametric EQ','Четыре полосы: частота, усиление и добротность каждой.','Four bands, each with frequency, gain and Q.'),
 ('HighPass','Фильтр высоких частот','High-pass filter',None,None),
 ('LowPass','Фильтр низких частот','Low-pass filter',None,None),
 ('BandPass','Полосовой фильтр','Band-pass filter',None,None),
 ('Notch','Режекторный фильтр','Notch filter','Вырезает узкую полосу частот (например, писк).','Removes a narrow frequency band (e.g. a whistle).'),
 ('HumRemoval','Удаление фона сети','Hum removal','Убирает гул 50/60 Гц и его гармоники.','Removes 50/60 Hz mains hum and its harmonics.'),
 ('Deesser','Де-эссер','De-esser','Смягчает резкие «с» и «ш».','Softens harsh "s" and "sh" sounds.'),
 ('Exciter','Эксайтер','Exciter','Добавляет яркости и разборчивости высоким частотам.','Adds brightness and clarity to the highs.'),
 ('NoiseReduction','Подавление шума','Noise reduction','Убирает постоянный шум (шипение, гул). Лучше всего — с профилем шума из участка без речи.','Removes steady noise (hiss, hum). Works best with a noise profile from a part without speech.'),
 ('NlmDenoise','Шумоподавление NLM','NLM denoise','Шумоподавление по нелокальным средним: мягче, но медленнее.','Non-local means denoising: gentler but slower.'),
 ('ClickRemoval','Удаление щелчков','Click removal','Убирает щелчки и треск (виниловые записи).','Removes clicks and crackle (vinyl recordings).'),
 ('ClipFix','Восстановление перегрузки','Clip fix','Восстанавливает срезанные вершины волны.','Reconstructs clipped peaks.'),
 ('ChangePitch','Смена высоты тона','Change pitch','Меняет высоту без изменения темпа.','Changes pitch without changing tempo.'),
 ('ChangeTempo','Смена темпа','Change tempo','Меняет темп без изменения высоты тона.','Changes tempo without changing pitch.'),
 ('ChangeSpeed','Смена скорости','Change speed','Меняет скорость и высоту вместе, как на магнитофоне.','Changes speed and pitch together, like a tape deck.'),
 ('SlidingSpeed','Плавное изменение скорости','Sliding speed','Скорость плавно меняется от начала к концу выделения.','Speed changes smoothly from the start to the end of the selection.'),
 ('Paulstretch','Paulstretch','Paulstretch','Экстремальное растяжение во времени: превращает звук в атмосферный эмбиент.','Extreme time stretching: turns sound into ambient textures.'),
 ('Echo','Эхо','Echo','Повторения звука с затуханием.','Repeats the sound with decay.'),
 ('Reverb','Реверберация','Reverb','Звучание помещения: от комнаты до собора.','The sound of a space, from a room to a cathedral.'),
 ('Distortion','Искажение','Distortion','Перегруз разных типов: мягкий ламповый или жёсткий.','Overdrive of different kinds: soft tube-like or hard.'),
 ('Bitcrusher','Биткрашер','Bitcrusher','Снижает разрядность и частоту — «8-битный» звук.','Reduces bit depth and sample rate for an 8-bit sound.'),
 ('Phaser','Фейзер','Phaser',None,None),
 ('Flanger','Флэнжер','Flanger',None,None),
 ('Chorus','Хорус','Chorus',None,None),
 ('Tremolo','Тремоло','Tremolo','Периодически меняет громкость.','Periodically changes volume.'),
 ('Vibrato','Вибрато','Vibrato','Периодически меняет высоту тона.','Periodically changes pitch.'),
 ('Wahwah','Вау-вау','Wahwah','Плавающий резонансный фильтр, как педаль у гитариста.','A sweeping resonant filter, like a guitar pedal.'),
 ('AutoPan','Автопанорама','Auto pan','Звук плавно перемещается между каналами.','Sound moves between the channels.'),
 ('Invert','Инверсия','Invert','Переворачивает волну (фазу).','Flips the waveform (phase).'),
 ('Reverse','Реверс','Reverse','Проигрывает выделение задом наперёд.','Plays the selection backwards.'),
 ('Repeat','Повтор','Repeat','Повторяет выделение заданное число раз.','Repeats the selection a number of times.'),
 ('TruncateSilence','Сокращение тишины','Truncate silence','Укорачивает длинные паузы.','Shortens long pauses.'),
 ('VocalRemove','Удаление вокала','Vocal reduction','Убирает звук из центра стереопанорамы (обычно вокал), сохраняя басы.','Removes centre-panned audio (usually vocals) while keeping the bass.'),
 ('VocalIsolate','Выделение вокала','Vocal isolation','Оставляет центр панорамы в полосе голоса.','Keeps the centre of the stereo image in the voice range.'),
 ('SwapChannels','Поменять каналы местами','Swap channels',None,None),
 ('MonoMix','Свести в моно','Mono mix',None,None),
 ('StereoWiden','Расширение стерео','Stereo widener','Делает стереобазу шире.','Makes the stereo image wider.'),
 ('Balance','Баланс','Balance',None,None),
 ('Haas','Эффект Хааса','Haas effect','Превращает моно в объёмное стерео за счёт небольшой задержки одного канала.','Turns mono into wide stereo by slightly delaying one channel.'),
]
for idd, ru, en, rud, end in fx:
    k('fx'+idd, ru, en)
    if rud: k('fx'+idd+'Desc', rud, end)
k('fxFadeDesc','Плавно меняет громкость на выделении.','Smoothly changes volume across the selection.')
k('fxPassDesc','Пропускает только нужные частоты; крутизна задаёт, насколько резко срезаются остальные.','Lets only the wanted frequencies through; the slope sets how sharply the rest is cut.')
k('fxModulationDesc','Классический эффект модуляции задержкой.','A classic delay-modulation effect.')
k('fxChannelsDesc','Работа с каналами стерео.','Stereo channel tools.')
params = [
 ('Gain','Усиление','Gain'),('Peak','Пик','Peak'),('RemoveDc','Убрать смещение DC','Remove DC offset'),('Independent','Каналы независимо','Channels independently'),
 ('Lufs','Целевая громкость','Target loudness'),('TruePeak','Истинный пик, не выше','True peak ceiling'),('Threshold','Порог','Threshold'),('Ratio','Степень сжатия','Ratio'),
 ('Attack','Атака','Attack'),('Release','Восстановление','Release'),('Makeup','Компенсация усиления','Make-up gain'),('Knee','Мягкость перегиба','Knee'),
 ('Limit','Предел','Limit'),('Reduction','Подавление','Reduction'),('GateReduction','Ослабление ниже порога','Reduction below threshold'),('Duck','Насколько приглушать','Duck amount'),
 ('Frame','Длина окна','Frame length'),('Gauss','Сглаживание (окон)','Smoothing (frames)'),('PeakLin','Целевой пик','Target peak'),('MaxGain','Макс. усиление','Max gain'),
 ('Expansion','Макс. расширение','Max expansion'),('Compression','Макс. сжатие','Max compression'),('Curve','Форма кривой','Curve'),('From','Начальная громкость','Initial volume'),
 ('To','Конечная громкость','Final volume'),('Shape','Шкала','Scale'),('Bass','Басы','Bass'),('Treble','Высокие','Treble'),('Freq','Частота','Frequency'),
 ('Slope','Крутизна','Roll-off'),('Octaves','Ширина, октав','Width, octaves'),('Q','Добротность (Q)','Q'),('Mains','Частота сети','Mains frequency'),('Harmonics','Гармоник','Harmonics'),
 ('Intensity','Интенсивность','Intensity'),('MaxReduction','Макс. подавление','Max reduction'),('FreqPos','Частота срабатывания','Frequency position'),('Amount','Сила','Amount'),
 ('Drive','Драйв','Drive'),('Floor','Уровень шума','Noise floor'),('TrackNoise','Следить за изменением шума','Track changing noise'),('Strength','Сила','Strength'),
 ('Window','Окно','Window'),('Semitones','Сдвиг','Shift'),('Formants','Сохранять форманты (голос)','Preserve formants (voice)'),('Hq','Высокое качество','High quality'),
 ('Percent','Изменение','Change'),('Stretch','Растяжение','Stretch factor'),('Delay','Задержка','Delay'),('Decay','Затухание','Decay'),('ReverbTime','Время реверберации','Reverb time'),
 ('Predelay','Предзадержка','Pre-delay'),('Damping','Демпфирование','Damping'),('Wet','Уровень эффекта','Wet level'),('Dry','Исходный звук','Dry level'),('Type','Тип','Type'),
 ('Output','Выходной уровень','Output level'),('Bits','Разрядность','Bit depth'),('Downsample','Понижение частоты','Sample reduction'),('Mix','Смешивание','Mix'),('Speed','Скорость','Speed'),
 ('Depth','Глубина','Depth'),('Regen','Обратная связь','Feedback'),('Resonance','Резонанс','Resonance'),('Offset','Смещение частоты','Frequency offset'),('Times','Число повторов','Times'),
 ('MinSilence','Мин. длина тишины','Minimum silence'),('Keep','Оставить паузу','Keep pause'),('KeepBass','Сохранять басы ниже','Keep bass below'),('Low','Нижняя граница','Low cut'),
 ('High','Верхняя граница','High cut'),('Balance','Баланс','Balance'),('Waveform','Форма волны','Waveform'),('Amp','Амплитуда','Amplitude'),('FreqStart','Начальная частота','Start frequency'),
 ('FreqEnd','Конечная частота','End frequency'),('Log','Логарифмическая развёртка','Logarithmic sweep'),('Color','Цвет шума','Noise color'),('Bpm','Темп','Tempo'),('Beats','Долей в такте','Beats per bar'),
]
for idd, ru, en in params: k('fxp'+idd, ru, en)
k('fxpBandFreq','Полоса {n}: частота','Band {n}: frequency', n='int'); k('fxpBandGain','Полоса {n}: усиление','Band {n}: gain', n='int'); k('fxpBandQ','Полоса {n}: добротность','Band {n}: Q', n='int')
for idd, ru, en in [('Linear','линейная','linear'),('Qsin','четверть синуса','quarter sine'),('Hsin','половина синуса','half sine'),('Esin','экспонента синуса','exponential sine'),('Log','логарифмическая','logarithmic'),('Ipar','обратная парабола','inverted parabola'),('Qua','квадратичная','quadratic'),('Cub','кубическая','cubic'),('Squ','квадратный корень','square root'),('Cbr','кубический корень','cubic root'),('Par','парабола','parabola'),('Exp','экспоненциальная','exponential')]:
    k('curve'+idd, ru, en)
k('shapeLinear','линейная','linear'); k('shapeDb','в децибелах','in decibels')
k('waveSine','синус','sine'); k('waveSquare','меандр','square'); k('waveSawtooth','пила','sawtooth'); k('waveTriangle','треугольник','triangle')
for idd, ru, en in [('White','белый','white'),('Pink','розовый','pink'),('Brown','коричневый','brown'),('Blue','синий','blue'),('Violet','фиолетовый','violet'),('Velvet','бархатный','velvet')]:
    k('noise'+idd, ru, en)
for idd, ru, en in [('Hard','жёсткое ограничение','hard clip'),('Tanh','гиперболический тангенс','tanh'),('Atan','арктангенс','arctangent'),('Cubic','кубическое','cubic'),('Exp','экспоненциальное','exponential'),('Alg','алгебраическое','algebraic'),('Quintic','пятой степени','quintic'),('Sin','синусоидальное','sine'),('Erf','функция ошибок','error function')]:
    k('clip'+idd, ru, en)
k('genTone','Тон','Tone'); k('genChirp','Чирп (качающийся тон)','Chirp'); k('genNoise','Шум','Noise'); k('genSilence','Тишина','Silence'); k('genMetronome','Метроном','Rhythm track'); k('genDtmf','Тоны DTMF','DTMF tones')

exec(open(os.path.join(HERE, 'stage3b.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage3c.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage3d.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage3e.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage4a.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage4b.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage4c.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage5a.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage5b.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage5c.py'), encoding='utf-8').read())
exec(open(os.path.join(HERE, 'stage6.py'), encoding='utf-8').read())

def ph_meta(ph):
    return {'placeholders': {n: {'type': t} for n, t in ph.items()}} if ph else None

for lang in ('ru','en'):
    out = {'@@locale': lang}
    for key,(ru,en,ph) in S.items():
        out[key] = ru if lang=='ru' else en
        if lang=='ru':
            m = ph_meta(ph)
            if m: out['@'+key] = m
    json.dump(out, open(os.path.join(ROOT, 'lib', 'l10n', f'app_{lang}.arb'), 'w', encoding='utf-8'), ensure_ascii=False, indent=2)
print(len(S))
