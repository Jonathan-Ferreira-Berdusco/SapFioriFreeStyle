CLASS zcl_zov_mpc_ext DEFINITION
  PUBLIC
  INHERITING FROM zcl_zov_mpc
  CREATE PUBLIC .

  PUBLIC SECTION.

    "Campos da ordem e do item"
    TYPES: BEGIN OF ty_ordem_item,
             ordemid     TYPE i,
             datacriacao TYPE timestamp,
             criadopor   TYPE c LENGTH 20,
             clienteid   TYPE i,
             totalitens  TYPE p LENGTH 8 DECIMALS 2,
             totalfrete  TYPE p LENGTH 8 DECIMALS 2,
             totalordem  TYPE p LENGTH 8 DECIMALS 2,
             status      TYPE c LENGTH 1,
             toovitem    TYPE TABLE OF ts_ovitem WITH DEFAULT KEY, "Campo da propriedade de navegação"
           END OF ty_ordem_item.

    METHODS define REDEFINITION.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_ZOV_MPC_EXT IMPLEMENTATION.


  METHOD define.

    DATA: lo_entity_type TYPE REF TO /iwbep/if_mgw_odata_entity_typ.

    super->define( ).

    lo_entity_type = model->get_entity_type( iv_entity_name = 'OVcabecalho' ).
    lo_entity_type->bind_structure( iv_structure_name = 'ZCL_ZOV_MPC_EXT=>TY_ORDEM_ITEM' ).

  ENDMETHOD.
ENDCLASS.
