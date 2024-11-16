// Programa   : DPCTAPRESUP_INDEF
// Fecha/Hora : 15/01/2024 16:10:26
// Propósito  : Crea Registro Indefinido
// Creado Por : Juan Navas
// Llamado por:
// Aplicación :
// Tabla      :

#INCLUDE "DPXBASE.CH"

PROCE MAIN()
  LOCAL oDb:=OpenOdbc(oDp:cDsnData)

  oDp:cCtaPre:="Indefinida"

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"DPGRU","GRU_CTAPRE")

    EJECUTAR("DPCAMPOSADD"   ,"DPGRU","GRU_CTAPRE","C",20 ,0,"Cuenta Presupuestaria")
    EJECUTAR("SETFIELDEFAULT","DPGRU","GRU_CTAPRE",[&oDp:cCtaPre])
    EJECUTAR("DPLINKADD"     ,"DPCTAPRESUP"  ,"DPGRU","CPP_CODIGO","GRU_CTAPRE",.T.,.T.,.T.)

    EJECUTAR("DPCAMPOSADD","DPCTAPRESUP","CPP_CTAMOD","C",6  ,0,"Código Ejercicio")
    EJECUTAR("SETFIELDEFAULT","DPCTAPRESUP","CPP_CTAMOD",[&oDp:cCtaMod])

  ENDIF

  IF ISSQLFIND("DPCTAPRESUP","CPP_CODIGO"+GetWhere("=",oDp:cCtaPre))

    EJECUTAR("DPCTAINDEF")

    EJECUTAR("CREATERECORD","DPCTAPRESUP",{"CPP_CODIGO" ,"CPP_DESCRI","CPP_CTAMOD","CPP_CODCTA" },;
                                          {oDp:cCtaPre  ,"Indefinida",oDp:cCtaMod ,oDp:cCtaIndef},;
                                           NIL,.T.,"CPP_CODIGO"+GetWhere("=",oDp:cCtaPre))

   ENDIF

  IF !EJECUTAR("ISFIELDMYSQL",oDb,"NMOTRASNM","OTR_CTAPRE") .OR. .T.

    EJECUTAR("DPCAMPOSADD"   ,"NMOTRASNM","OTR_CTAPRE","C",20 ,0,"Cuenta Presupuestaria")
    EJECUTAR("SETFIELDEFAULT","NMOTRASNM","OTR_CTAPRE",[&oDp:cCtaPre])
    EJECUTAR("DPLINKADD"     ,"DPCTAPRESUP"  ,"NMOTRASNM","CPP_CODIGO","OTR_CTAPRE",.T.,.T.,.T.)

    EJECUTAR("DPCAMPOSADD","DPCTAPRESUP","CPP_CTAMOD","C",6  ,0,"Código Ejercicio")
    EJECUTAR("SETFIELDEFAULT","DPCTAPRESUP","CPP_CTAMOD",[&oDp:cCtaMod])

  ENDIF

  SQLUPDATE("NMOTRASNM","OTR_CTAPRE",oDp:cCtaPre,[OTR_CTAPRE IS NULL OR OTR_CTAPRE=""])  

? oDp:cSql

RETURN NIL
// EOF

