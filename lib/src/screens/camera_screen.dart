import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState(); //creamos el estado de la camrara
}

enum WidgetState { NONE, LOADING, LOADED, ERROR } //con esta linea de aca sabemos en que estado esta el widget

class _CameraScreenState extends State<CameraScreen> {
  WidgetState _widgetState = WidgetState.NONE; //creamos una variable simple la cual ira cmabiando segun el estado
  List<CameraDescription> _cameras;//instanciamos las camaras
  CameraController _cameraController; //method private



  @override
  void initState() { //la primera vez que se abra la aplicacion ya tenemso que inizializar el widget camra
    super.initState();
    initializeCamera();//con esta linea ejecutamos la camara
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) { //cambiamos la interface de usuario dependiendo del estado en que estemos
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    switch (_widgetState) {
      case WidgetState.NONE:
      case WidgetState.LOADING:
        return buildScaffold( // definimos una funcion scaffol que revise un body
            context, Center(child: CircularProgressIndicator())); //En estado none colocamos un botoncito de carga
      case WidgetState.LOADED:
        return buildScaffold(
            context,
            Stack(
              children: [
                Transform.scale(
                    scale: _cameraController.value.aspectRatio / deviceRatio,
                    child: AspectRatio(
                        aspectRatio: _cameraController.value.aspectRatio,
                        child: CameraPreview(_cameraController))),
              ],
            ));
      case WidgetState.ERROR:
        return buildScaffold(
            context,
            Center(
                child: Text(
                    "¡Ooops! Error al cargar la cámara 😩. Reinicia la apliación.")));
    }
    return Container();
  }

  Widget buildScaffold(BuildContext context, Widget body) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Cámara"),
        backgroundColor: Colors.transparent,
        elevation: 0, //propiedad para quitar la sombra
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try { //recibe el parametro body
            final path = join(
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            await _cameraController.takePicture(path); //este metodo es propio roma la foto
            Navigator.pop(context, path); // retornamos la ruta de la foto
          } catch (e) {
            print(e);
          }
        },
        child: Icon(Icons.camera), //Definimos el icono del boton
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, //boton ubicacion
    );
  }

  Future<void> initializeCamera() async {
    _widgetState = WidgetState.LOADING;
    if (mounted) setState(() {}); //actualizamos el estado del widget

    _cameras = await availableCameras(); //funcion propia que nos devuelve las camaras



    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);//nos traemos todas las camaras del dispositivo si tine mas de una
    // y definimos la relacion de aspecto
    await _cameraController.initialize(); //con el aprametro await siempre espara a que nuestro widget este listo para usarse
    //Preguntamos si ha habido algun tipo de error retunr un boolean
    if (_cameraController.value.hasError) {
      _widgetState = WidgetState.ERROR;//verificamos si el widget ya esta motnando si ya funciona el metodo
      if (mounted) setState(() {}); //No cambiamos nada ya que sucede un error
    } else {
      _widgetState = WidgetState.LOADED; //y si lo esta le damos el estado al widget
      if (mounted) setState(() {});
    }
  }
}
