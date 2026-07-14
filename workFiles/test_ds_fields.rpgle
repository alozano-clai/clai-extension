// Prueba específica para validar campos DS como vlngt_n
// Caso reportado por el usuario

dcl-s global_var char(10);  // Variable global normal

// Caso 1: DS con campos que el usuario reportó como problemáticos
dcl-ds vlngt len(4);
  vlngt_a  char(4)  pos(1);
  vlngt_n  zoned(4) pos(1);   // Esta NO debería marcarse como "no definida"  
end-ds;

// Caso 2: Otro DS para probar diferentes tipos
dcl-ds xVal len(20);
  xVal_A  char(20)  pos(1);
  xVal_N  zoned(20) pos(1);   // Estos tampoco deberían marcarse como "no definidas"
end-ds;

// Caso 3: DS qualified para comparar
dcl-ds employee qualified;
  name char(30);              // Este debería requerir employee.name
  id zoned(5);
end-ds;

//=================================================================*
// Uso de las variables para probar detección
//=================================================================*

dcl-proc test_ds_fields;
  dcl-pi *n;
    vlista char(20) const;
  end-pi;
  
  // Estas líneas NO deberían mostrar error "variable no definida"
  vlngt_n = %len(%trim(vlista));     // vlngt_n está definida en DS vlngt
  vlngt_a = 'TEST';                  // vlngt_a está definida en DS vlngt
  
  xVal_N = 12345;                    // xVal_N está definida en DS xVal  
  xVal_A = 'HELLO WORLD';            // xVal_A está definida en DS xVal
  
  // Esta SÍ debería mostrar error porque es DS qualified  
  // name = 'John';                  // Error: debe ser employee.name
  
  // Uso correcto de DS qualified
  employee.name = 'John Doe';        // Correcto
  employee.id = 123;                 // Correcto
  
  global_var = 'Used';               // Variable global normal
  
end-proc;