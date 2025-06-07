// web/flutter_bootstrap.js
// Este archivo se usa para configurar el cargador de Flutter en la web.

// Configuración para el motor de Flutter.
// Aquí es donde definimos el proxy y otras opciones.
const flutterConfiguration = {
  // Especificamos el renderer aquí: 'html' para mayor compatibilidad.
  // Esto reemplaza el antiguo flag --web-renderer.
  renderer: 'html',

  // Configuración del proxy para las solicitudes de la API de Google Places.
  // Esto redirige las solicitudes a maps.googleapis.com
  // a través del servidor de desarrollo de Flutter, evitando problemas de CORS.
  // Es crucial que esta URL sea la misma que la de tu API de Google Places.
  // No incluyas la clave API aquí, ya que se añade en el código Dart.
  httpProxies: {
    'https://maps.googleapis.com/': {
      target: 'https://maps.googleapis.com/',
      // No se necesitan headers adicionales para Google Places normalmente.
    },
  },
};

// Carga el motor de Flutter con la configuración.
// Esta es la forma moderna de inicializar Flutter Web.
_flutter.loader.load(flutterConfiguration).then(function(engineInitializer) {
  engineInitializer.initializeEngine().then(function(appRunner) {
    appRunner.runApp();
  });
});