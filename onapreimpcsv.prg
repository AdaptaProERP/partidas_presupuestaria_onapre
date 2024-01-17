// Programa   : ONAPREIMPCSV
// Fecha/Hora : 19/11/2019 21:39:22
// Propósito  : Importar Plan de Cuentas
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN(cFile,lReset)
  LOCAL aData,I
  LOCAL oTable

  DEFAULT cFile :="EJEMPLO\ONAPRE.CSV",;
          lReset:=.T.

  IF !FILE(cFile)
     RETURN .F.
  ENDIF

  IF lReset
    SQLDELETE("DPCTAPRESUP")
  ENDIF

//  ? FILE(cFile)
  aData:=MEMOREAD(cFile)
  aData:=STRTRAN(aData,CRLF,CHR(10))

  aData:=_VECTOR(aData,CHR(10))

  AEVAL(aData,{|a,n| aData[n]:=_VECTOR(a,";")})

  ADEPURA(aData,{|a,n| !ISDIGIT(LEFT(a[1],1))})

  oTable:=OpenTable("SELECT * FROM DPCTAPRESUP",.F.)
  oTable:lAuditar:=.F.
  oTable:SetForeignkeyOff()

  FOR I=1 TO LEN(aData)

    oTable:AppendBlank()
    oTable:Replace("CPP_CODIGO",aData[I,1])
    oTable:Replace("CPP_CODCTA",aData[I,6])
    oTable:Replace("CPP_DESCRI",aData[I,2])
    oTable:Replace("CPP_NIVEL" ,aData[I,3])
    oTable:Replace("CPP_TIPO"  ,aData[I,4])
    oTable:Replace("CPP_ACTIVO",.T.       )
    oTable:Commit()

  NEXT I

  oTable:End()


//ViewArray(aData)
  
RETURN NIL

/*
 C001=CPP_CODCTA          ,'C',020,0,'','Cuenta Contable',0
 C002=CPP_CODIGO          ,'C',020,0,'PRIMARY KEY NOT NULL','C¾digo',0
 C003=CPP_DESCRI          ,'C',040,0,'','Descripci¾n',0
 C004=CPP_ITEM            ,'C',005,0,'','Item',1
 C005=CPP_NIVEL           ,'N',002,0,'','Nivel',0
 C006=CPP_NUMMEM          ,'N',008,0,'','N·mero de Memo',0
 C007=CPP_PUBLI           ,'C',001,0,'','Publicaci¾n',0
 C008=CPP_TIPO            ,'C',001,0,'','Tipo',0
*/
// EOF
