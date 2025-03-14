class ZCL_ZOV_DPC_EXT definition
  public
  inheriting from ZCL_ZOV_DPC
  create public .

public section.
protected section.

  methods MENSAGEMSET_CREATE_ENTITY
    redefinition .
  methods MENSAGEMSET_DELETE_ENTITY
    redefinition .
  methods MENSAGEMSET_GET_ENTITY
    redefinition .
  methods MENSAGEMSET_GET_ENTITYSET
    redefinition .
  methods MENSAGEMSET_UPDATE_ENTITY
    redefinition .
  methods OVCABECALHOSET_CREATE_ENTITY
    redefinition .
  methods OVCABECALHOSET_DELETE_ENTITY
    redefinition .
  methods OVCABECALHOSET_GET_ENTITY
    redefinition .
  methods OVCABECALHOSET_GET_ENTITYSET
    redefinition .
  methods OVCABECALHOSET_UPDATE_ENTITY
    redefinition .
  methods OVITEMSET_CREATE_ENTITY
    redefinition .
  methods OVITEMSET_DELETE_ENTITY
    redefinition .
  methods OVITEMSET_GET_ENTITY
    redefinition .
  methods OVITEMSET_GET_ENTITYSET
    redefinition .
  methods OVITEMSET_UPDATE_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZOV_DPC_EXT IMPLEMENTATION.


  method MENSAGEMSET_CREATE_ENTITY.

  endmethod.


  method MENSAGEMSET_DELETE_ENTITY.

  endmethod.


  method MENSAGEMSET_GET_ENTITY.

  endmethod.


  method MENSAGEMSET_GET_ENTITYSET.

  endmethod.


  method MENSAGEMSET_UPDATE_ENTITY.

  endmethod.


  METHOD ovcabecalhoset_create_entity.

    DATA:ld_lastid TYPE int4, "variavel com função de incrementar o OrdemID"
         ls_cabe   TYPE zovcab.

    "Objeto para emitir mensagem para quem estiver consumindo o serviço"
    DATA(lo_msg) = me->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Pegando os dados da requisição"
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    "Copiando os da entidade para a estrutura"
    MOVE-CORRESPONDING er_entity TO ls_cabe.

    "Preenchendo os campos que faltam na estrutura"
    ls_cabe-criacao_data    = sy-datum.
    ls_cabe-criacao_hora    = sy-uzeit.
    ls_cabe-criacao_usuario = sy-uname.

    "Pegando o ultimo ID"
    SELECT SINGLE MAX( ordemid )
      INTO ld_lastid
      FROM zovcab.

    "Incrementando mais +1 no ID"
    ls_cabe-ordemid = ld_lastid + 1.

    "Inserindo os novos dados na tabela ZOVCAB com base na estrutura"
    INSERT zovcab FROM ls_cabe.

    IF sy-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao inserir ordem'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

    "Atualizando a Entidade com todos os campos preenchidos"
    MOVE-CORRESPONDING ls_cabe TO er_entity.

    CONVERT
       DATE ls_cabe-criacao_data
       TIME ls_cabe-criacao_hora
       INTO TIME STAMP er_entity-datacriacao
       TIME ZONE sy-zonlo.

  ENDMETHOD.


  method OVCABECALHOSET_DELETE_ENTITY.

  endmethod.


  method OVCABECALHOSET_GET_ENTITY.
    er_entity-ordemid = 1.
    er_entity-criadopor = 'Jonathan'.
    er_entity-datacriacao = '19700101000000'.
  endmethod.


  method OVCABECALHOSET_GET_ENTITYSET.

  endmethod.


  method OVCABECALHOSET_UPDATE_ENTITY.

  endmethod.


  METHOD ovitemset_create_entity.

    DATA: LS_ITEM TYPE zovitem.

    "Objeto de mensagem"
    DATA(LO_MSG) = ME->/iwbep/if_mgw_conv_srv_runtime~get_message_container( ).

    "Carregando os dados da requisição e copiando para 'er_entity'"
    io_data_provider->read_entry_data(
      IMPORTING
        es_data = er_entity
    ).

    "Movendo os dados para a estrutura"
    MOVE-CORRESPONDING er_entity TO ls_item.

    "Caso o ID do item venha vazio, ele preenche pegando o último ID da tabela"
    IF er_entity-itemid = 0.
      SELECT SINGLE MAX( ITEMID )
        INTO er_entity-itemid
        FROM zovitem
        WHERE ordemid = er_entity-ordemid.

      "Auto incremento"
      er_entity-itemid = er_entity-itemid + 1.
    ENDIF.

    "Inserindo na tabela ZOVITEM"
    INSERT zovitem FROM ls_item.

    "Caso de um erro na inserção, ele cria uma msg de erro"
    IF SY-subrc <> 0.
      lo_msg->add_message_text_only(
        EXPORTING
          iv_msg_type = 'E'
          iv_msg_text = 'Erro ao inserir o item na tabela ZOVITEM'
      ).

      RAISE EXCEPTION TYPE /iwbep/cx_mgw_busi_exception
        EXPORTING
          message_container = lo_msg.
    ENDIF.

  ENDMETHOD.


  method OVITEMSET_DELETE_ENTITY.

  endmethod.


  method OVITEMSET_GET_ENTITY.

  endmethod.


  method OVITEMSET_GET_ENTITYSET.

  endmethod.


  method OVITEMSET_UPDATE_ENTITY.

  endmethod.
ENDCLASS.
