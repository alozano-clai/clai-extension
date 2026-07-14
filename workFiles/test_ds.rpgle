// Archivo de prueba para funcionalidades de Data Structures
// RPGLE Unused Detector v0.5.0 - Data Structure Support

dcl-s mi_nombre char(20);
dcl-s unused_var zoned(5); // Esta variable no se usa - debería mostrar warning

// DS Qualified - debe usarse con sintaxis de punto
dcl-ds employee qualified;
  name char(30);
  id zoned(5);
  salary packed(7:2);  // Campo no usado - debería mostrar warning
end-ds;

// DS No Qualified - campos usables directamente
dcl-ds address;
  street char(50);
  city char(30);
  zipcode zoned(5);    // Campo no usado - debería mostrar warning
end-ds;

// DS Anónimo - campos usables directamente
dcl-ds *n;
  wlongn  zoned(4:0);
  wlongc  char(4) overlay(wlongn);
end-ds;

// DS Externo con qualified
dcl-ds customerData ext inz(*extdft) extname('CUSTOMER') qualified end-ds;

//=================================================================*
// Ejemplos de uso
//=================================================================*

// Uso correcto de DS qualified
employee.name = 'Juan Perez';     // Correcto: uso con punto
employee.id = 12345;              // Correcto: uso con punto

// Uso incorrecto - debería mostrar error
// name = 'Error';                // Error: debe ser employee.name para DS qualified

// Uso correcto de DS no qualified
street = 'Calle Principal 123';   // Correcto: DS no qualified
city = 'Medellín';                // Correcto: DS no qualified

// Uso correcto de DS anónimo  
wlongn = 1234;                    // Correcto: DS anónimo
wlongc = 'ABCD';                  // Correcto: DS anónimo

// Asignación final
mi_nombre = employee.name;

//=================================================================*
// CASOS DE PRUEBA ESPECÍFICOS
//=================================================================*

dcl-proc test_procedure;
  dcl-pi *n;
    input_param char(10) const;
  end-pi;
  
  // DS local dentro de procedimiento
  dcl-ds local_ds qualified;
    field1 char(20);
    field2 zoned(5);
  end-ds;
  
  local_ds.field1 = input_param;  // Uso correcto
  // local_ds.field2 no se usa - warning esperado
  
end-proc;