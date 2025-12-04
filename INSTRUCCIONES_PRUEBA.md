# Instrucciones de Prueba - Verificar que el Bug Está Solucionado

## Antes de empezar
```bash
cd "C:\Users\carlo\Desktop\AGEND\AgendaFio"
flutter clean
flutter pub get
flutter run
```

## PRUEBA 1: Verificar aislamiento de días

### Pasos:
1. La app abre y muestra el calendario del mes actual
2. Selecciona el **DÍA 1** del mes
3. En la sección "Gastos del Día" deberá estar vacía
4. Haz clic en el botón **"+"** para añadir un gasto
5. Rellena:
   - Producto: `Almuerzo`
   - Precio: `15.50`
6. Haz clic en "Guardar"
7. Deberá ver el gasto en la lista con el "Total del día: $15.50"

### Verificación:
8. Selecciona el **DÍA 2** (día siguiente)
9. **❌ BUG SOLUCIONADO SI**: La sección muestra "No hay gastos para este día"
10. **❌ BUG NO SOLUCIONADO SI**: Muestra el mismo gasto "Almuerzo $15.50"

## PRUEBA 2: Añadir múltiples gastos en el mismo día

### Pasos:
1. Asegúrate de estar en el **DÍA 1**
2. Haz clic en **"+"** para añadir otro gasto
3. Rellena:
   - Producto: `Cena`
   - Precio: `22.00`
4. Haz clic en "Guardar"
5. Debería ver dos gastos:
   - Almuerzo: $15.50
   - Cena: $22.00
6. **"Total del día"** debe mostrar: **$37.50**

## PRUEBA 3: Verificar independencia de meses

### Pasos:
1. Observa la esquina superior derecha: "Total del Mes: $37.50"
2. Navega al **PRÓXIMO MES** (usa las flechas del calendario)
3. Verifica que el "Total del Mes" sea: **$0.00**
4. Navega de vuelta al **MES ANTERIOR**
5. Verifica que el "Total del Mes" sigue siendo: **$37.50**

### ✅ Resultado esperado:
- Cada mes tiene su propio total independiente
- Los gastos de un mes NO afectan al total de otro mes

## PRUEBA 4: Prueba de eliminación

### Pasos:
1. En el **DÍA 1** (donde guardaste Almuerzo y Cena)
2. Localiza el gasto "Almuerzo $15.50"
3. En la parte derecha, haz clic en el **icono de papelera**
4. Se abrirá un diálogo confirmando la eliminación
5. Haz clic en **"Eliminar"**

### ✅ Resultado esperado:
- El gasto "Almuerzo" desaparece
- Solo queda "Cena: $22.00"
- "Total del día" cambia a: **$22.00**
- El gasto se elimina de Firestore instantáneamente

## PRUEBA 5: Verificar persistencia

### Pasos:
1. Cierra la app completamente (swipe o X)
2. Vuelve a abrir la app
3. El calendario debería mostrar los mismos datos

### ✅ Resultado esperado:
- Día 1: Cena $22.00 (sin Almuerzo, que fue eliminado)
- Total del mes: $22.50 (si tenías otros gastos)
- Todos los datos se mantienen

## PRUEBA 6: Prueba de migración de datos

Esta prueba solo aplica si tenías datos antes de las correcciones:

### ✅ Si tenías datos antiguos:
- La app se inicia
- Los datos antiguos se convierten automáticamente
- Todo funciona correctamente sin intervención manual

## ✅ CHECKLIST DE VALIDACIÓN

Marca cada prueba como completada:

```
☐ PRUEBA 1: Aislamiento de días - ✅ PASADA
☐ PRUEBA 2: Múltiples gastos mismo día - ✅ PASADA  
☐ PRUEBA 3: Independencia de meses - ✅ PASADA
☐ PRUEBA 4: Eliminación de gastos - ✅ PASADA
☐ PRUEBA 5: Persistencia de datos - ✅ PASADA
☐ PRUEBA 6: Migración automática - ✅ PASADA
```

Si todas las pruebas pasan: **✅ EL BUG ESTÁ COMPLETAMENTE SOLUCIONADO**

## Posibles problemas y soluciones

### Problema: No aparece "Total del Mes"
- **Solución**: Verifica que hayas seleccionado un día. El total solo aparece cuando hay un día seleccionado.

### Problema: Los datos no persisten
- **Solución**: Asegúrate de tener conexión a internet (Firestore requiere conexión)

### Problema: La migración tarda mucho
- **Solución**: Si tienes muchos datos antiguos, espera a que termine. Solo ocurre una vez.

### Problema: Aún ves gastos mezclados entre días
- **Solución**: Ejecuta:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

## Contacto para issues
Si aún encuentras problemas, verifica:
1. Que tengas Dart 3.9+ (`flutter --version`)
2. Que Firebase esté correctamente configurado
3. Los logs de Firestore para ver si hay errores de escritura
