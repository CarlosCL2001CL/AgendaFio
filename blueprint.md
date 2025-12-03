# Blueprint: AgendaFio

## Visión General

AgendaFio es una aplicación móvil diseñada para ayudar a los usuarios a llevar un registro diario de sus gastos. La aplicación se centra en una interfaz de calendario simple e intuitiva, permitiendo a los usuarios añadir productos y precios por día y ver un resumen mensual de sus gastos. La autenticación de usuarios y el almacenamiento de datos se gestionan de forma segura a través de Firebase.

## Funcionalidades Implementadas

*   **Autenticación de Usuarios:**
    *   Registro de nuevos usuarios con correo y contraseña.
    *   Inicio de sesión para usuarios existentes.
    *   Sistema seguro de restablecimiento de contraseña a través de correo electrónico, integrado con SendGrid para garantizar la entrega de los correos.

*   **Diseño y Estilo:**
    *   Pantalla de inicio de sesión y registro con un diseño limpio, campos de entrada claros y botones distintivos.

## Plan de Desarrollo Actual: Calendario de Gastos

El objetivo actual es implementar la funcionalidad principal de la aplicación: el calendario de gastos.

**Pasos a seguir:**

1.  **[COMPLETADO] Añadir Dependencia de Calendario:** Se ha añadido el paquete `table_calendar` al proyecto para la creación de la interfaz del calendario.

2.  **Crear Pantalla del Calendario (`CalendarScreen`):**
    *   Diseñar una nueva pantalla que será la principal después del inicio de sesión.
    *   Integrar el widget `TableCalendar` para mostrar el calendario.
    *   Añadir un área para mostrar la lista de gastos del día seleccionado.
    *   Añadir un campo de texto para mostrar el total de gastos del mes en curso.
    *   La pantalla será un `StatefulWidget` para gestionar el día seleccionado, los eventos y los cálculos.

3.  **Implementar Formulario de Nuevo Gasto:**
    *   Al tocar un día en el calendario, se mostrará un `AlertDialog` (diálogo emergente).
    *   Este diálogo contendrá un formulario con dos campos: "Producto" (texto) y "Precio" (numérico, en dólares).
    *   Incluirá un botón "Guardar" para registrar el gasto.

4.  **Integración con Cloud Firestore:**
    *   Crear una nueva colección en Firestore llamada `expenses`.
    *   Cada vez que un usuario guarda un nuevo gasto, se creará un nuevo documento en esta colección con la siguiente estructura:
        *   `userId`: El ID único del usuario (obtenido de Firebase Auth).
        *   `date`: La fecha del gasto (en formato `Timestamp`).
        *   `productName`: El nombre del producto.
        *   `price`: El precio del producto.
    *   Esta estructura asegura que cada usuario solo pueda ver sus propios gastos.

5.  **Cargar y Mostrar Datos:**
    *   La `CalendarScreen` leerá los datos de la colección `expenses` en tiempo real.
    *   Filtrará los gastos para mostrar solo los que pertenecen al usuario que ha iniciado sesión.
    *   Al seleccionar un día, la lista de gastos se actualizará para mostrar las entradas de esa fecha.
    *   Se calculará la suma de todos los gastos del mes visible y se mostrará en el total mensual.

6.  **Actualizar Flujo de Navegación:**
    *   Modificar la lógica de inicio de sesión para que, tras una autenticación exitosa, el usuario sea redirigido a la nueva `CalendarScreen`.
