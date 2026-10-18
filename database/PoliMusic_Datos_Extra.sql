/* ============================================================================
   PoliMusic | Datos complementarios
   ----------------------------------------------------------------------------
   Script OPCIONAL que se ejecuta DESPUES de BDD_PoliMusic.sql.

   Que hace:
     1. Crea los dos usuarios normales solicitados en la practica
        (Axel.Manotoa y Claudio Penaherrera) si todavia no existen.
     2. Convierte a hash SHA-1 las contrasenas que sigan guardadas en texto
        plano (userNormal, userAdmin).

   Es idempotente: se puede ejecutar varias veces sin duplicar registros.
   Nota: la aplicacion tambien convierte la contrasena a SHA-1 de forma
   automatica la primera vez que un usuario inicia sesion, por lo que este
   script solo sirve para dejar la base ordenada desde el principio.

   Ejecucion:
     sqlcmd -S localhost -E -i "database\PoliMusic_Datos_Extra.sql"
     (o abrir el archivo en SQL Server Management Studio y ejecutarlo)
   ============================================================================ */

USE [BDD_PoliMusic];
GO

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------------
   1. Usuarios normales de la practica
   ------------------------------------------------------------------------ */

IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'Axel.Manotoa')
BEGIN
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE)
    VALUES ('Axel.Manotoa',
            CONVERT(VARCHAR(40), HASHBYTES('SHA1', CAST('12345678' AS VARCHAR(50))), 2),
            'axel.manotoa@epn.edu.ec', '2002-05-14', '~/userImages/default.jpg', 0);
    PRINT 'Usuario Axel.Manotoa creado.';
END
ELSE
    PRINT 'Usuario Axel.Manotoa ya existe.';
GO

IF NOT EXISTS (SELECT 1 FROM TBL_USER WHERE USERNAME = 'Claudio Penaherrera')
BEGIN
    INSERT INTO TBL_USER (USERNAME, PASSWORD, EMAIL, BIRTHDAY, USER_PHOTO, USER_TYPE)
    VALUES ('Claudio Penaherrera',
            CONVERT(VARCHAR(40), HASHBYTES('SHA1', CAST('claudio10' AS VARCHAR(50))), 2),
            'claudio.penaherrera@epn.edu.ec', '2001-08-22', '~/userImages/default.jpg', 0);
    PRINT 'Usuario Claudio Penaherrera creado.';
END
ELSE
    PRINT 'Usuario Claudio Penaherrera ya existe.';
GO

/* ---------------------------------------------------------------------------
   2. Contrasenas en texto plano -> hash SHA-1 (40 caracteres hexadecimales)
   ------------------------------------------------------------------------ */
UPDATE TBL_USER
   SET PASSWORD = CONVERT(VARCHAR(40), HASHBYTES('SHA1', CAST(PASSWORD AS VARCHAR(50))), 2)
 WHERE LEN(PASSWORD) <> 40;
PRINT CAST(@@ROWCOUNT AS VARCHAR(10)) + ' contrasena(s) convertida(s) a hash SHA-1.';
GO

/* ---------------------------------------------------------------------------
   3. Verificacion
   ------------------------------------------------------------------------ */
SELECT ID_USER,
       USERNAME,
       USER_TYPE,
       CASE WHEN LEN(PASSWORD) = 40 THEN 'SHA-1' ELSE 'texto plano' END AS FORMATO_CLAVE,
       EMAIL
  FROM TBL_USER
 ORDER BY USER_TYPE DESC, USERNAME;
GO
