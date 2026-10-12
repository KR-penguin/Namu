// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Namu';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonRetry => 'Intentar de nuevo';

  @override
  String get commonRetryShort => 'Reintentar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonApprove => 'Aprobar';

  @override
  String get commonExport => 'Exportar';

  @override
  String get commonAttachedPhoto => 'Foto adjunta';

  @override
  String commonDiaryStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'finalized': 'Definitivo',
      'draft': 'Borrador',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String commonWeekday(String weekday) {
    String _temp0 = intl.Intl.selectLogic(weekday, {
      'monday': 'lunes',
      'tuesday': 'martes',
      'wednesday': 'miércoles',
      'thursday': 'jueves',
      'friday': 'viernes',
      'saturday': 'sábado',
      'sunday': 'domingo',
      'other': 'día desconocido',
    });
    return '$_temp0';
  }

  @override
  String commonFullDate(int year, int month, int day) {
    return '$day/$month/$year';
  }

  @override
  String commonFullDateWithWeekday(
    int year,
    int month,
    int day,
    String weekday,
  ) {
    return '$weekday, $day/$month/$year';
  }

  @override
  String commonMonthDayWithWeekday(int month, int day, String weekday) {
    return '$weekday, $day/$month';
  }

  @override
  String get bootstrapResetDeleting =>
      'Eliminando los datos locales de este dispositivo…';

  @override
  String get bootstrapResetFailedTitle =>
      'No se pudieron terminar de eliminar tus datos';

  @override
  String get bootstrapResetFailedBody =>
      'Namu se detuvo de forma segura sin volver a abrir tus registros. Intenta eliminarlos de nuevo.';

  @override
  String get bootstrapResetRetry => 'Intentar eliminar de nuevo';

  @override
  String get bootstrapTimeZoneFailedTitle =>
      'No se pudo cargar tu zona horaria';

  @override
  String get bootstrapTimeZoneFailedBody =>
      'Namu necesita tu zona horaria para mantener separados los registros de cada día.';

  @override
  String get gatewayPreservedChat =>
      'Tu mensaje sigue guardado en este dispositivo.';

  @override
  String get gatewayPreservedDiary =>
      'El registro de hoy sigue guardado en este dispositivo.';

  @override
  String gatewayUnknownChat(String preserved) {
    return 'No se pudo obtener una respuesta de la IA. $preserved';
  }

  @override
  String gatewayUnknownDiary(String preserved) {
    return 'No se pudo crear un borrador del diario. $preserved';
  }

  @override
  String gatewayUnconfigured(String preserved) {
    return 'Es necesario configurar la conexión con la IA. $preserved';
  }

  @override
  String gatewayUnauthorized(String preserved) {
    return 'No se pudo verificar la conexión con la IA. Inténtalo de nuevo en unos instantes. $preserved';
  }

  @override
  String gatewayInvalidAttestation(String preserved) {
    return 'No se pudo verificar este dispositivo para acceder a la IA. Vuelve a abrir la aplicación e inténtalo de nuevo. $preserved';
  }

  @override
  String gatewayRateLimited(String retryGuidance, String preserved) {
    return 'La IA está recibiendo demasiadas solicitudes en este momento. $retryGuidance $preserved';
  }

  @override
  String get gatewayRequestTooLargeChat =>
      'Este mensaje es demasiado largo para enviarlo a la IA. Divídelo en un mensaje nuevo e inténtalo de nuevo. El original sigue guardado en este dispositivo.';

  @override
  String gatewayRequestTooLargeDiary(String preserved) {
    return 'El registro de hoy es demasiado largo para enviarlo a la IA. $preserved';
  }

  @override
  String gatewayResponseTooLarge(String preserved) {
    return 'La respuesta de la IA era demasiado larga, por lo que no se mostró. Inténtalo de nuevo. $preserved';
  }

  @override
  String get gatewayIdempotencyConflictChat =>
      'No se puede volver a intentar esta solicitud de forma segura. Empieza un mensaje nuevo. El original sigue guardado en este dispositivo.';

  @override
  String gatewayIdempotencyConflictDiary(String preserved) {
    return 'No se puede volver a intentar esta solicitud de forma segura. Vuelve a abrir la aplicación e inténtalo de nuevo. $preserved';
  }

  @override
  String gatewayRejected(String preserved) {
    return 'La IA no pudo procesar esta solicitud. Revísala e inténtalo de nuevo. $preserved';
  }

  @override
  String gatewaySafetyBlockedChat(String preserved) {
    return 'Las reglas de seguridad de la IA impiden responder a esta solicitud. $preserved';
  }

  @override
  String gatewaySafetyBlockedDiary(String preserved) {
    return 'Las reglas de seguridad de la IA impiden crear un borrador del diario a partir de esta solicitud. $preserved';
  }

  @override
  String gatewayTimeout(String preserved) {
    return 'La respuesta de la IA estaba tardando demasiado, así que Namu dejó de esperar. Inténtalo de nuevo. $preserved';
  }

  @override
  String gatewayTruncated(String preserved) {
    return 'La respuesta de la IA estaba incompleta, por lo que no se mostró. Inténtalo de nuevo. $preserved';
  }

  @override
  String gatewayInvalidResponse(String preserved) {
    return 'No se pudo verificar el formato de la respuesta de la IA, por lo que no se mostró. Inténtalo de nuevo. $preserved';
  }

  @override
  String gatewayServerUnavailable(String preserved) {
    return 'El servicio de IA está temporalmente inestable. Inténtalo de nuevo en unos instantes. $preserved';
  }

  @override
  String gatewayNetworkUnavailable(String preserved) {
    return 'No se pudo conectar a la red. Comprueba tu conexión e inténtalo de nuevo. $preserved';
  }

  @override
  String get gatewayRetrySoon => 'Inténtalo de nuevo en unos instantes.';

  @override
  String gatewayRetryAfterSeconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inténtalo de nuevo dentro de aproximadamente $count segundos.',
      one: 'Inténtalo de nuevo dentro de aproximadamente 1 segundo.',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inténtalo de nuevo dentro de aproximadamente $count minutos.',
      one: 'Inténtalo de nuevo dentro de aproximadamente 1 minuto.',
    );
    return '$_temp0';
  }

  @override
  String gatewayRetryAfterHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Inténtalo de nuevo dentro de aproximadamente $count horas.',
      one: 'Inténtalo de nuevo dentro de aproximadamente 1 hora.',
    );
    return '$_temp0';
  }

  @override
  String get archiveSearchSemantics => 'Buscar en el archivo del diario';

  @override
  String get archiveSearchLabel => 'Buscar en el archivo';

  @override
  String get archiveSearchHint =>
      '04/10/2026, estado de ánimo o resumen en una línea';

  @override
  String get archiveClearSearchTooltip => 'Borrar búsqueda';

  @override
  String get archiveTitle => 'Archivo del diario';

  @override
  String get archiveSubtitle =>
      'Vuelve a los días guardados en este dispositivo';

  @override
  String get archiveReloadTooltip => 'Actualizar la lista de diarios';

  @override
  String get archiveLoadingSemantics => 'Cargando el archivo del diario';

  @override
  String get archiveNoResultsSemantics =>
      'No hay resultados de búsqueda en el diario';

  @override
  String get archiveNoResultsTitle => 'No se encontraron resultados';

  @override
  String get archiveNoResultsBody =>
      'Busca una fecha como 04/10/2026 o prueba con otras palabras del estado de ánimo o del resumen en una línea.';

  @override
  String get archiveEmptySemantics => 'Archivo del diario vacío';

  @override
  String get archiveEmptyTitle => 'Todavía no hay diarios guardados';

  @override
  String get archiveEmptyBody =>
      'Crea un diario a partir de la conversación de hoy y aquí se irán reuniendo tus días.';

  @override
  String get archiveLoadErrorSemantics => 'Error al cargar el diario';

  @override
  String get archiveLoadErrorTitle => 'No se pudieron cargar tus diarios';

  @override
  String get archiveStoredDataSafeBody =>
      'Tus datos guardados no han cambiado. Inténtalo de nuevo en unos instantes.';

  @override
  String get archiveRefreshError =>
      'No se pudo actualizar. Aún puedes ver los diarios que ya se cargaron.';

  @override
  String archiveEntrySemantics(
    String date,
    String mood,
    String status,
    String summary,
  ) {
    return '$date, estado de ánimo $mood, $status, $summary';
  }

  @override
  String archiveMoodLabel(String mood) {
    return 'Estado de ánimo · $mood';
  }

  @override
  String get archiveOpenDiarySemantics => 'Abrir el diario';

  @override
  String get chatLoadError => 'No se pudo cargar tu conversación guardada.';

  @override
  String get chatPhotoPickerUnavailable =>
      'La selección de fotos no está disponible en este entorno.';

  @override
  String get chatPrompt => 'Cuéntame cómo ha ido tu día';

  @override
  String get chatLocalFirstBody =>
      'Los mensajes se guardan en este dispositivo antes de enviarse a la IA.';

  @override
  String chatAiFriendProfileSemantics(String name) {
    return 'Perfil del acompañante de IA $name';
  }

  @override
  String get chatGatewaySetupNeeded =>
      'Es necesario configurar la conexión con la IA';

  @override
  String get chatAiReady => 'Todo listo para recibir respuestas de la IA';

  @override
  String get chatConsentNeeded =>
      'Se requiere tu consentimiento para compartir datos con la IA';

  @override
  String get chatPersonaSettingsTooltip => 'Ajustes del acompañante de IA';

  @override
  String get chatConnectionBadgeNeedsSetup => 'Falta configurar la IA';

  @override
  String get chatConnectionBadgeReady => 'IA lista';

  @override
  String get chatConnectionBadgeNeedsConsent => 'Falta el consentimiento';

  @override
  String get chatTodayDivider => 'Hoy';

  @override
  String chatPersonaProfileSemantics(String name) {
    return 'Perfil de $name';
  }

  @override
  String get chatReplyFailed => 'No se pudo obtener una respuesta de la IA';

  @override
  String get chatTypingSemantics => 'La IA está escribiendo una respuesta';

  @override
  String get chatOpenDiary => 'Ver el diario de hoy';

  @override
  String get chatAttachPhotoTooltip => 'Adjuntar foto';

  @override
  String get chatSendMessageTooltip => 'Enviar mensaje';

  @override
  String get consentDisclosureSemantics =>
      'Aviso sobre el uso de datos por la IA';

  @override
  String get consentTitle => 'Información que se envía a la IA';

  @override
  String get consentTransferBody =>
      'Para crear respuestas de la IA y borradores del diario, Namu envía el texto que escribes, una parte limitada de las conversaciones recientes, los recuerdos aprobados, tu perfil de IA y la información de las fotos adjuntas al AI Gateway configurado.';

  @override
  String get consentPhotoBoundaryBody =>
      'Actualmente no se envían los archivos de foto originales. Solo se envían los identificadores de las fotos y su posición en la conversación. Se requerirá un consentimiento independiente antes de que cualquier función futura de análisis de fotos pueda enviar su contenido.';

  @override
  String get consentLocalUseBody =>
      'Los chats, los diarios y las fotos originales se guardan en este dispositivo. Puedes usar los registros locales sin dar tu consentimiento, y puedes darlo o retirarlo en cualquier momento desde Ajustes.';

  @override
  String get consentSaveFailed =>
      'No se pudo guardar tu elección. Inténtalo de nuevo.';

  @override
  String get consentAcceptAndStart =>
      'Aceptar compartir datos con la IA y empezar';

  @override
  String get consentDeclineAndUseLocal =>
      'Usar los registros locales sin aceptar';

  @override
  String get consentLoadError =>
      'No se pudo comprobar tu ajuste para compartir datos con la IA.\nNo se enviará ninguna solicitud a la IA hasta que se compruebe.';

  @override
  String get consentSettingsTitle => 'Uso de datos por la IA';

  @override
  String consentSettingsStatus(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'allowed': 'Uso de datos por la IA: permitido',
      'declined': 'Uso de datos por la IA: no permitido',
      'other': 'Uso de datos por la IA: sin decidir',
    });
    return '$_temp0';
  }

  @override
  String get consentSettingsRequestBody =>
      'Cuando solicitas una respuesta de la IA o un borrador del diario, Namu envía tu texto, una parte limitada de las conversaciones recientes, los recuerdos aprobados, el perfil de IA y la información de las fotos adjuntas al AI Gateway configurado.';

  @override
  String get consentSettingsPhotoBody =>
      'Actualmente no se envían los archivos de foto originales. Si retiras tu consentimiento, las futuras solicitudes a la IA se bloquean de inmediato y tus registros locales siguen disponibles.';

  @override
  String get consentSettingsSaveFailed =>
      'No se pudo guardar este ajuste. Inténtalo de nuevo.';

  @override
  String get consentRevoke => 'Retirar el consentimiento';

  @override
  String get consentAccept => 'Aceptar compartir datos con la IA';

  @override
  String get diaryEditorValidationError =>
      'Comprueba el estado de ánimo, el tiempo, el resumen en una línea y el contenido del diario.';

  @override
  String get diaryEditorSaveFailed =>
      'No se pudo guardar el diario. Inténtalo de nuevo.';

  @override
  String get diaryEditorTitle => 'Editar el diario de hoy';

  @override
  String get diaryEditorSubtitle =>
      'Puedes cambiar el tiempo, el estado de ánimo, el resumen en una línea, el texto y el orden de las fotos del borrador de la IA.';

  @override
  String get diaryEditorMoodLabel => 'Estado de ánimo de hoy';

  @override
  String get diaryEditorSummaryLabel => 'Hoy en una línea';

  @override
  String get diaryEditorWeatherTitle => 'Tiempo';

  @override
  String get diaryEditorWeatherSubtitle =>
      'Introduce el tiempo de hoy sin permitir el acceso a tu ubicación.';

  @override
  String get diaryEditorWeatherConditionLabel => 'Condiciones';

  @override
  String get diaryEditorWeatherConditionHint => 'Soleado, nublado, lluvia';

  @override
  String get diaryEditorTemperatureLabel => 'Temperatura (°C)';

  @override
  String get diaryEditorOptionalHint => 'Opcional';

  @override
  String get diaryEditorBackgroundLabel => 'Fondo';

  @override
  String get diaryEditorLightBackground => 'Fondo claro';

  @override
  String get diaryEditorDarkBackground => 'Fondo oscuro';

  @override
  String get diaryEditorContentTitle => 'Texto y fotos';

  @override
  String get diaryEditorAddParagraph => 'Añadir párrafo';

  @override
  String get diaryEditorSaveChanges => 'Guardar cambios';

  @override
  String get diaryEditorMoveUpTooltip => 'Subir';

  @override
  String get diaryEditorMoveDownTooltip => 'Bajar';

  @override
  String get diaryEditorRemoveBlockTooltip => 'Eliminar bloque';

  @override
  String get diaryEditorParagraphLabel => 'Párrafo';

  @override
  String get diaryPreviewFinalizedHelp =>
      'Al compartir se abre la pantalla para compartir de este dispositivo; eso no significa que el diario se haya publicado.';

  @override
  String get diaryPreviewDraftHelp =>
      'Este es un borrador generado por la IA. Revísalo y edítalo antes de convertirlo en definitivo.';

  @override
  String get diaryPreviewTitle => 'Registro de hoy';

  @override
  String get diaryPreviewCreateSubtitle =>
      'Crea un borrador del diario a partir de tu conversación';

  @override
  String get diaryPreviewStoredSubtitle =>
      'Guardado en este dispositivo · se conserva el historial de edición';

  @override
  String get diaryPreviewEmptyTitle => 'Todavía no hay un diario para hoy';

  @override
  String get diaryPreviewEmptyCanGenerate =>
      'Convierte la conversación de hoy en un borrador del diario con texto y fotos.';

  @override
  String get diaryPreviewEmptyNeedsChat =>
      'Empieza contando algo sobre tu día.';

  @override
  String get diaryPreviewGenerating => 'Creando borrador';

  @override
  String get diaryPreviewGenerate => 'Crear el diario de hoy';

  @override
  String diaryPreviewPageSemantics(int currentPage, int pageCount) {
    return 'Página $currentPage de $pageCount del diario';
  }

  @override
  String diaryPreviewPageIndicator(int currentPage, int pageCount) {
    return '$currentPage / $pageCount';
  }

  @override
  String get diaryPreviewPreviousPageTooltip => 'Página anterior del diario';

  @override
  String get diaryPreviewNextPageTooltip => 'Página siguiente del diario';

  @override
  String get diaryPreviewOneLineLabel => 'Hoy en una línea';

  @override
  String get diaryPreviewBrandSemantics => 'Diario Namu';

  @override
  String get diaryPreviewBrandHeading => 'DIARIO NAMU';

  @override
  String get diaryWeatherNone => 'Sin información del tiempo';

  @override
  String get diaryWeatherManualSource => 'Introducido manualmente';

  @override
  String diaryWeatherSourceAndCondition(String source, String condition) {
    return '$source · $condition';
  }

  @override
  String diaryWeatherSourceConditionTemperature(
    String source,
    String condition,
    String temperature,
  ) {
    return '$source · $condition $temperature°';
  }

  @override
  String get diaryEditAction => 'Editar';

  @override
  String get diaryShareAction => 'Compartir';

  @override
  String get diaryFinalizeAction => 'Convertir en definitivo';

  @override
  String get memoryApproveFailed =>
      'No se pudo aprobar este recuerdo. Inténtalo de nuevo.';

  @override
  String get memoryEditFailed =>
      'No se pudo editar este recuerdo. Inténtalo de nuevo.';

  @override
  String get memoryDeleteFailed =>
      'No se pudo eliminar este recuerdo. Inténtalo de nuevo.';

  @override
  String get memoryActivateFailed =>
      'No se pudo volver a usar este recuerdo. Inténtalo de nuevo.';

  @override
  String get memoryDeactivateFailed =>
      'No se pudo dejar de usar este recuerdo. Inténtalo de nuevo.';

  @override
  String get memoryTitle => 'Memoria de la IA';

  @override
  String get memorySubtitle =>
      'Revisa y gestiona los datos que se usan en futuras conversaciones';

  @override
  String get memoryReloadTooltip => 'Actualizar la lista de recuerdos';

  @override
  String get memoryLoadingSemantics => 'Cargando la lista de recuerdos';

  @override
  String get memoryEmptySemantics => 'Memoria de la IA vacía';

  @override
  String get memoryEmptyTitle => 'Todavía no hay recuerdos guardados';

  @override
  String get memoryEmptyBody =>
      'Cuando apruebes un recuerdo propuesto en un resumen diario, podrás gestionarlo aquí.';

  @override
  String get memoryLoadErrorSemantics => 'Error al cargar los recuerdos';

  @override
  String get memoryLoadErrorTitle => 'No se pudieron cargar tus recuerdos';

  @override
  String get memoryStoredDataSafeBody =>
      'Tus datos guardados no han cambiado. Inténtalo de nuevo en unos instantes.';

  @override
  String get memoryRefreshError =>
      'No se pudo actualizar. Aún puedes ver los recuerdos que ya se cargaron.';

  @override
  String memoryCardSemantics(String fact, String status, String category) {
    return 'Recuerdo, $fact, estado $status, categoría $category';
  }

  @override
  String get memorySensitiveApprovalNotice =>
      'Recuerdo sensible · requiere aprobación';

  @override
  String get memoryChangingSemantics => 'Actualizando el recuerdo';

  @override
  String get memoryDeactivateAction => 'Dejar de usar';

  @override
  String get memoryActivateAction => 'Volver a usar';

  @override
  String get memoryEditAction => 'Editar texto';

  @override
  String get memoryApproveSensitiveTitle =>
      '¿Quieres usar este recuerdo sensible?';

  @override
  String get memoryApproveRegularTitle => '¿Quieres usar este recuerdo?';

  @override
  String get memoryApproveSensitiveBody =>
      'Si lo apruebas, podrá usarse en futuras conversaciones con la IA. Revisa el contenido y decide por tu cuenta.';

  @override
  String get memoryApproveRegularBody =>
      'Solo los recuerdos aprobados se pueden usar como contexto en futuras conversaciones con la IA.';

  @override
  String get memoryEditValidationError =>
      'Escribe algo para que la IA lo recuerde.';

  @override
  String get memoryEditDialogTitle => 'Editar el texto del recuerdo';

  @override
  String get memoryEditFieldLabel => 'Dato que la IA debe recordar';

  @override
  String get memoryDeleteDialogTitle => '¿Quieres eliminar este recuerdo?';

  @override
  String get memoryDeleteDialogBody =>
      'Ya no se usará en conversaciones con la IA. Esta acción no se puede deshacer.';

  @override
  String memoryStatusLabel(String status) {
    String _temp0 = intl.Intl.selectLogic(status, {
      'candidate': 'Pendiente de revisión',
      'active': 'En uso',
      'inactive': 'Sin usar',
      'other': 'Desconocido',
    });
    return '$_temp0';
  }

  @override
  String memoryCategoryLabel(String category) {
    String _temp0 = intl.Intl.selectLogic(category, {
      'preference': 'Preferencia',
      'routine': 'Rutina',
      'relationship': 'Relación',
      'place': 'Lugar',
      'milestone': 'Hito',
      'other': 'Otro',
    });
    return '$_temp0';
  }

  @override
  String get onboardingSemantics => 'Información para empezar';

  @override
  String get onboardingTitle => 'Antes de empezar';

  @override
  String get onboardingLocalStorageTitle =>
      'Tus registros permanecen en este dispositivo';

  @override
  String get onboardingLocalStorageBody =>
      'Los chats, los diarios y las fotos permanecen en el almacenamiento privado de la aplicación. No se ofrecen sincronización en la nube, copias de seguridad ni restauración en otro dispositivo. Si eliminas la aplicación o pierdes el dispositivo, tus registros no se podrán recuperar.';

  @override
  String get onboardingAiDisclosureTitle => 'Conversación con una IA';

  @override
  String get onboardingAiDisclosureBody =>
      'Tu acompañante de IA es una IA generativa, no una persona. Responde de forma cercana, pero puede equivocarse; verifica por separado las decisiones importantes.';

  @override
  String get onboardingAiTransferTitle =>
      'Compartir datos con la IA es opcional';

  @override
  String get onboardingAiTransferBody =>
      'Si das tu consentimiento, tu texto, una parte limitada de los chats recientes, los recuerdos aprobados, el perfil de IA y la información de las fotos adjuntas se envían al AI Gateway configurado para crear respuestas y borradores del diario. Actualmente no se envían los archivos de foto originales.';

  @override
  String get onboardingDecisionNote =>
      'Puedes usar los registros locales sin decidirlo ahora. Más adelante, desde Ajustes, puedes aceptar compartir datos con la IA o retirar tu consentimiento.';

  @override
  String get onboardingSaveFailed =>
      'No se pudo guardar tu elección. Inténtalo de nuevo.';

  @override
  String get onboardingAcceptAi =>
      'Aceptar compartir datos con la IA y empezar';

  @override
  String get onboardingStartLocal => 'Empezar sin IA por ahora';

  @override
  String get onboardingLoadError =>
      'No se pudo comprobar tu estado de configuración inicial.';

  @override
  String get personaDefaultName => 'Moa';

  @override
  String get personaDefaultTone => 'Cálida y curiosa';

  @override
  String get personaAvatarSprout => 'Brote';

  @override
  String get personaAvatarLeaf => 'Hoja';

  @override
  String get personaAvatarSunlight => 'Luz del sol';

  @override
  String get personaAvatarMoonlight => 'Luz de luna';

  @override
  String get personaValidationError =>
      'Comprueba el nombre y el estilo de conversación.';

  @override
  String get personaSaveFailed =>
      'No se pudieron guardar estos ajustes. Inténtalo de nuevo.';

  @override
  String get personaSettingsTitle => 'Ajustes del acompañante de IA';

  @override
  String get personaSettingsSubtitle =>
      'Elige el nombre y el estilo de conversación de un único acompañante de IA. Tus instrucciones nunca prevalecen sobre las reglas de seguridad.';

  @override
  String get personaNameLabel => 'Nombre';

  @override
  String get personaProfileLabel => 'Perfil';

  @override
  String get personaToneLabel => 'Tono y personalidad';

  @override
  String get personaToneHint => 'Por ejemplo: cálida y curiosa';

  @override
  String get personaReactionLengthLabel => 'Longitud de las respuestas';

  @override
  String get personaReactionConcise => 'Breve';

  @override
  String get personaReactionBalanced => 'Equilibrada';

  @override
  String get personaReactionExpressive => 'Expresiva';

  @override
  String get personaInstructionsLabel =>
      'Preferencias de conversación adicionales (opcional)';

  @override
  String get personaInstructionsHint =>
      'Por ejemplo: haz solo una pregunta cada vez.';

  @override
  String get personaAiConsentAction => 'Ajustes del uso de datos por la IA';

  @override
  String get settingsExportDialogTitle =>
      '¿Quieres exportar tus registros como JSON?';

  @override
  String get exportDialogBody =>
      'Se incluyen los chats, los diarios, los recuerdos, los ajustes del acompañante de IA y el estado de tu consentimiento para compartir datos con la IA. No se incluyen las fotos originales ni las imágenes de publicaciones para compartir, y este archivo no permite restaurar la aplicación. Namu no puede retirar ni eliminar las copias que compartas con otras aplicaciones o guardes como archivos.';

  @override
  String get settingsExportOpened =>
      'Se abrió la pantalla para compartir y guardar.';

  @override
  String get settingsExportCancelled => 'Se canceló la exportación.';

  @override
  String get settingsExportUnavailable =>
      'Este dispositivo no puede abrir la pantalla para compartir y guardar.';

  @override
  String get settingsExportFailed =>
      'No se pudieron exportar tus registros. Inténtalo de nuevo.';

  @override
  String get settingsDeleteAllDialogTitle =>
      '¿Quieres eliminar todos los datos locales?';

  @override
  String get settingsResetPreviewDialogTitle =>
      '¿Quieres restablecer los datos de la vista previa?';

  @override
  String get settingsDeleteAllDialogBody =>
      'Esto elimina de este dispositivo los chats, los diarios, las fotos, los ajustes del acompañante de IA, los recuerdos de la IA, los archivos de exportación de la aplicación y el consentimiento para compartir datos con la IA. No se puede deshacer. Namu no puede eliminar las copias exportadas a otras aplicaciones o guardadas como archivos.';

  @override
  String get settingsResetPreviewDialogBody =>
      'Esto restablece únicamente los datos temporales de esta vista previa en el navegador. No confirma la eliminación de los datos almacenados en el dispositivo.';

  @override
  String get settingsDeleteAllAction => 'Eliminar todo';

  @override
  String get settingsAiSectionTitle => 'IA';

  @override
  String get settingsPersonaTitle => 'Ajustes del acompañante de IA';

  @override
  String get settingsPersonaSubtitle =>
      'Nombre, tono, perfil y longitud de las respuestas';

  @override
  String get settingsConsentTitle => 'Ajustes del uso de datos por la IA';

  @override
  String get settingsConsentSubtitle => 'Revisa o retira tu consentimiento';

  @override
  String get settingsMyDataSectionTitle => 'Mis datos';

  @override
  String get settingsTransientStorageTitle =>
      'Almacenamiento temporal del navegador';

  @override
  String get settingsDeviceStorageTitle =>
      'Almacenados únicamente en este dispositivo';

  @override
  String get settingsTransientStorageBody =>
      'Esta vista previa en el navegador usa datos temporales que pueden desaparecer cuando se reinicie.';

  @override
  String get settingsDeviceStorageBody =>
      'Los chats, los diarios y las fotos se guardan en este dispositivo y no se pueden recuperar después de eliminar la aplicación o perder el dispositivo.';

  @override
  String get settingsExportJsonTitle => 'Exportar registros como JSON';

  @override
  String get settingsExportWebUnavailable =>
      'La exportación no está disponible en la vista previa del navegador.';

  @override
  String get settingsExportJsonSubtitle =>
      'Exporta los chats, los diarios, los recuerdos y los ajustes de la IA como JSON. No se incluyen los archivos de foto.';

  @override
  String get settingsResetPreviewTitle =>
      'Restablecer los datos de la vista previa';

  @override
  String get settingsDeleteAllTitle => 'Eliminar todos los datos locales';

  @override
  String get settingsResetPreviewSubtitle =>
      'Borra únicamente el estado temporal actual, no los datos del dispositivo.';

  @override
  String get settingsDeleteAllSubtitle =>
      'Elimina de forma permanente los datos de la aplicación, incluido el consentimiento para compartir datos con la IA.';

  @override
  String get settingsResetFailed =>
      'No se pudieron terminar de eliminar tus datos. Inténtalo de nuevo.';

  @override
  String get settingsExportShareText =>
      'Exportación JSON de los registros locales de Namu';

  @override
  String get shareSheetOpenedNotPosted =>
      'La pantalla para compartir está abierta. Comprueba en la aplicación seleccionada si se llegó a publicar algo.';

  @override
  String get shareRendererTodayTitle => 'Registro de hoy';

  @override
  String get shareRendererPhotoUnavailable => 'Foto no disponible';

  @override
  String shareRendererPageNumber(int pageNumber, int pageCount) {
    return '$pageNumber / $pageCount';
  }

  @override
  String shareRendererWeatherWithTemperature(
    String condition,
    String temperature,
  ) {
    return '$condition $temperature°C';
  }

  @override
  String shareCaptionMetadata(String date, String weather, String mood) {
    return '$date · $weather · $mood';
  }

  @override
  String get todayNoDiaryToEdit => 'No hay ningún diario que editar.';

  @override
  String get todayChatRefreshFailed =>
      'No se pudo actualizar la conversación de hoy.';

  @override
  String get todayPhotoAttachedReplyFailed =>
      'La foto se adjuntó, pero no llegó ninguna respuesta de la IA. Tu registro sigue guardado en este dispositivo.';

  @override
  String get todayPhotoMobileAndGatewayNeeded =>
      'La selección de fotos está disponible en la aplicación móvil. También es necesaria una conexión con AI Gateway.';

  @override
  String get todayConsentNeededForDiary =>
      'Acepta compartir datos con la IA para crear un borrador del diario.';

  @override
  String get todayFinalizeFailed =>
      'No se pudo guardar el diario como definitivo.';

  @override
  String get todayMemoryCandidatesFailed =>
      'El diario se guardó, pero Namu no pudo preparar las sugerencias de recuerdos.';

  @override
  String get todayNoDiaryToShare => 'No hay ningún diario que compartir.';

  @override
  String get todayShareUnavailable =>
      'La pantalla para compartir no está disponible en este entorno.';

  @override
  String get todayShareCancelled =>
      'Se canceló la acción de compartir. Tu diario sigue guardado en este dispositivo.';

  @override
  String get todayShareImageFailed =>
      'No se pudieron crear las imágenes para compartir. Inténtalo de nuevo.';

  @override
  String get todayDiaryAlreadyVisible =>
      'El diario de hoy está abierto a la derecha.';

  @override
  String get todayNavChat => 'Chat';

  @override
  String get todayNavDiary => 'Diario de hoy';

  @override
  String get todayNavArchive => 'Archivo';

  @override
  String get todayNavMemory => 'Memoria';

  @override
  String get todayNavSettings => 'Ajustes';
}
