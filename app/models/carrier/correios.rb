class Carrier::Correios < Carrier
  cattr_reader :name
  @@name = "Correios"

  # GENERAL DEFINITIONS
  TEST_URL = "https://apphom.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl"
  LIVE_URL = "https://apps.correios.com.br/SigepMasterJPA/AtendeClienteService/AtendeCliente?wsdl"
  SERVICES = ['PAC','SEDEX']
  TRACKING_URL = "https://rastreamentocorreios.info/consulta/{tracking}"

  ID_SERVICOS = {
    '40010' => "SEDEX sem contrato",
    '40045' => "SEDEX a Cobrar, sem contrato",
    '40126' => "SEDEX a Cobrar, com contrato",
    '40215' => "SEDEX 10, sem contrato",
    '40290' => "SEDEX Hoje, sem contrato",
    '40096' => "SEDEX com contrato",
    '40436' => "SEDEX com contrato",
    '40444' => "SEDEX com contrato",
    '40568' => "SEDEX com contrato",
    '40606' => "SEDEX com contrato",
    '41106' => "PAC sem contrato",
    '41068' => "PAC com contrato",
    '41211' => "PAC com contrato",
    '81019' => "e-SEDEX, com contrato",
    '81027' => "e-SEDEX Prioritário, com contrato",
    '81035' => "e-SEDEX Express, com contrato",
    '81868' => "(Grupo 1) e-SEDEX, com contrato",
    '81833' => "(Grupo 2 ) e-SEDEX, com contrato",
    '81850' => "(Grupo 3 ) e-SEDEX, com contrato",
  }

  STATUS_CODES = {
    ["ERROR", 0] => ["Problematic", "Objeto não encontrado", "", ""],  # custom status for "Not Found" error
    ["BDE", 0] => ["Delivered", "Objeto entregue ao destinatário", "Recebido por:", "Finalizar a entrega. Não é mais necessário prosseguir com o acompanhamento."],
    ["BDI", 0] => ["Delivered", "Objeto entregue ao destinatário", "Recebido por:", "Finalizar a entrega. Não é mais necessário prosseguir com o acompanhamento."],
    ["BDR", 0] => ["Delivered", "Objeto entregue ao destinatário", "Recebido por:", "Finalizar a entrega. Não é mais necessário prosseguir com o acompanhamento."],
    ["CAR", 1] => ["On the way", "Conferido", "Recebido na unidade de destino", "Acompanhar"],
    ["CD", 0] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["CMT", 0] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["CUN", 0] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["DO", 0] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["LDE", 0] => ["Out for delivery", "Objeto saiu para entrega ao remetente", "", "Acompanhar"],
    ["LDI", 0] => ["Waiting for pickup", "Objeto aguardando retirada no endereço indicado", "Endereço:", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["OEC", 0] => ["Out for delivery", "Objeto saiu para entrega ao destinatário", "", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["PO", 0] => ["On the way", "Objeto postado", "", "Acompanhar"],
    ["RO", 0] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["TRI", 0] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["BDE", 1] => ["Delivered", "Objeto entregue ao destinatário", "Recebido por:", "Finalizar a entrega. Não é mais necessário prosseguir com o acompanhamento."],
    ["BDI", 1] => ["Delivered", "Objeto entregue ao destinatário", "Recebido por:", "Finalizar a entrega. Não é mais necessário prosseguir com o acompanhamento."],
    ["BDR", 1] => ["Delivered", "Objeto entregue ao destinatário", "Recebido por:", "Finalizar a entrega. Não é mais necessário prosseguir com o acompanhamento."],
    ["BLQ", 1] => ["On the way", "Entrega de objeto bloqueada a pedido do remetente", "Objeto em análise de destinação", "Acompanhar"],
    ["BLQ", 2] => ["On the way", "Tentativa de suspensão da entrega", "Objeto em análise de destinação", "Acompanhar"],
    ["CD", 1] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["CO", 1] => ["On the way", "Objeto coletado", "", "Acompanhar"],
    ["CUN", 1] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["DO", 1] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["EST", 1] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["FC", 1] => ["On the way", "Objeto será devolvido por solicitação do remetente", "", "Acompanhar o retorno do objeto ao remetente."],
    ["FC", 10] => ["On the way", "Objeto recebido na unidade de distribuição", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["FC", 47] => ["On the way", "Objeto será devolvido por solicitação do contratante/remetente", "Em tratamento, aguarde.", "Acompanhar"],
    ["IDC", 1] => ["Problematic", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["LDI", 1] => ["Waiting for pickup", "Objeto aguardando retirada no endereço indicado", "Endereço:", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["OEC", 1] => ["On the way", "Objeto saiu para entrega ao destinatário", "", "Acompanhar"],
    ["PMT", 1] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["PO", 1] => ["On the way", "Objeto postado", "", "Acompanhar"],
    ["RO", 1] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["BDE", 2] => ["Waiting for pickup", "A entrega não pode ser efetuada - Carteiro não atendido", "Aguarde => Objeto estará disponível para retirada na unidade a ser informada.", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["BDI", 2] => ["Waiting for pickup", "A entrega não pode ser efetuada - Carteiro não atendido", "Aguarde => Objeto estará disponível para retirada na unidade a ser informada.", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["BDR", 2] => ["Waiting for pickup", "A entrega não pode ser efetuada - Carteiro não atendido", "Aguarde => Objeto estará disponível para retirada na unidade a ser informada.", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["CD", 2] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["DO", 2] => ["On the way", "Objeto encaminhado para", "<nome da cidade>", "Acompanhar"],
    ["EST", 2] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["FC", 2] => ["On the way", "Objeto com data de entrega agendada", "", "Acompanhar"],
    ["IDC", 2] => ["Lost", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["LDI", 2] => ["Waiting for pickup", "Objeto disponível para retirada em Caixa Postal", "", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["BDE", 3] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "Objeto em análise de destinação", "Acompanhar. O interessado não buscou o objeto na unidade dos Correios durante o período de guarda."],
    ["BDI", 3] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "Objeto em análise de destinação", "Acompanhar. O interessado não buscou o objeto na unidade dos Correios durante o período de guarda."],
    ["BDR", 3] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "Objeto em análise de destinação", "Acompanhar. O interessado não buscou o objeto na unidade dos Correios durante o período de guarda."],
    ["CD", 3] => ["On the way", "Objeto recebido na Unidade dos Correios", "", "Acompanhar"],
    ["EST", 3] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["FC", 3] => ["On the way", "Objeto mal encaminhado", "Encaminhamento a ser corrigido.", "Acompanhar"],
    ["IDC", 3] => ["Lost", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["LDI", 3] => ["Waiting for pickup", "Objeto aguardando retirada no endereço indicado", "Endereço:", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["BDE", 4] => ["Problematic", "A entrega não pode ser efetuada - Cliente recusou-se a receber", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 4] => ["Problematic", "A entrega não pode ser efetuada - Cliente recusou-se a receber", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 4] => ["Problematic", "A entrega não pode ser efetuada - Cliente recusou-se a receber", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["EST", 4] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["FC", 4] => ["On the way", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["IDC", 4] => ["Lost", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["BDE", 5] => ["Problematic", "A entrega não pode ser efetuada", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 5] => ["Problematic", "A entrega não pode ser efetuada", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 5] => ["Problematic", "A entrega não pode ser efetuada", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["EST", 5] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["FC", 5] => ["On the way", "Objeto devolvido aos Correios", "", "Acompanhar"],
    ["IDC", 5] => ["Lost", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["BDE", 6] => ["Problematic", "A entrega não pode ser efetuada - Cliente desconhecido no local", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 6] => ["Problematic", "A entrega não pode ser efetuada - Cliente desconhecido no local", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 6] => ["Problematic", "A entrega não pode ser efetuada - Cliente desconhecido no local", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["EST", 6] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["IDC", 6] => ["Lost", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["BDE", 7] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["BDI", 7] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["BDR", 7] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["FC", 7] => ["Out for delivery", "A entrega não pode ser efetuada - Empresa sem expediente", "A entrega deverá ocorrer no próximo dia útil", "Acompanhar"],
    ["IDC", 7] => ["Lost", "Objeto não localizado", "Houve indenização dos valores correspondentes", "Acompanhar"],
    ["BDE", 8] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 8] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 8] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["FC", 8] => ["On the way", "Área com distribuição sujeita a prazo diferenciado", "Restrição de entrega domiciliar temporária", "Acompanhar"],
    ["BDE", 9] => ["Lost", "Objeto não localizado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 9] => ["Lost", "Objeto não localizado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 9] => ["Lost", "Objeto não localizado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["EST", 9] => ["On the way", "Favor desconsiderar a informação anterior", "", "Acompanhar"],
    ["FC", 9] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "", "Acompanhar"],
    ["LDE", 9] => ["On the way", "Objeto saiu para entrega ao remetente", "", "Acompanhar"],
    ["OEC", 9] => ["On the way", "Objeto saiu para entrega ao remetente", "", "Acompanhar"],
    ["PO", 9] => ["On the way", "Objeto postado após o horário limite da agência", "Objeto sujeito a encaminhamento no próximo dia útil", "Acompanhar"],
    ["BDE", 10] => ["Problematic", "A entrega não pode ser efetuada - Cliente mudou-se", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 10] => ["Problematic", "A entrega não pode ser efetuada - Cliente mudou-se", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 10] => ["Problematic", "A entrega não pode ser efetuada - Cliente mudou-se", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 12] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "Objeto em análise de destinação", "Acionar atendimento dos Correios."],
    ["BDI", 12] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "Objeto em análise de destinação", "Acionar atendimento dos Correios."],
    ["BDR", 12] => ["Waiting for pickup", "Remetente não retirou objeto na Unidade dos Correios", "Objeto em análise de destinação", "Acionar atendimento dos Correios."],
    ["LDI", 4] => ["Waiting for pickup", "Objeto aguardando retirada no endereço indicado", "Endereço:", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["LDI", 14] => ["Waiting for pickup", "Objeto aguardando retirada no endereço indicado", "Endereço:", "Acompanhar. O interessado deverá buscar o objeto em uma Unidade dos Correios."],
    ["BDI", 14] => ["On the way", "Desistência de postagem pelo remetente", "", "Acompanhar"],
    ["BDR", 14] => ["On the way", "Desistência de postagem pelo remetente", "", "Acompanhar"],
    ["BDR", 15] => ["On the way", "Recebido na unidade de distribuição", "Por determinação judicial o objeto será entregue em até 7 dias", "Acompanhar"],
    ["PAR", 15] => ["delivered", "Objeto recebido em <destino>", "", "Acompanhar"],
    ["PAR", 16] => ["On the way", "Objeto recebido no Brasil", "Objeto sujeito à fiscalização e atraso na entrega", "Acompanhar"],
    ["PAR", 17] => ["On the way", "Objeto liberado pela alfândega", "", "Acompanhar"],
    ["PAR", 18] => ["On the way", "Objeto recebido na unidade de exportação", "", "Acompanhar"],
    ["BDE", 18] => ["On the way", "A entrega não pode ser efetuada - Carteiro não atendido", "Será realizada nova tentativa de entrega no sábado", "Acompanhar"],
    ["BDR", 18] => ["On the way", "A entrega não pode ser efetuada - Carteiro não atendido", "Será realizada nova tentativa de entrega no sábado", "Acompanhar"],
    ["BDE", 19] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 19] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 19] => ["Problematic", "A entrega não pode ser efetuada - Endereço incorreto", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 20] => ["Out for delivery", "A entrega não pode ser efetuada - Carteiro não atendido", "Será realizada nova tentativa de entrega", "Acompanhar"],
    ["BDI", 20] => ["Out for delivery", "A entrega não pode ser efetuada - Carteiro não atendido", "Será realizada nova tentativa de entrega", "Acompanhar"],
    ["BDR", 20] => ["Out for delivery", "A entrega não pode ser efetuada - Carteiro não atendido", "Será realizada nova tentativa de entrega", "Acompanhar"],
    ["BDE", 21] => ["Problematic", "A entrega não pode ser efetuada - Carteiro não atendido", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 21] => ["Problematic", "A entrega não pode ser efetuada - Carteiro não atendido", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 21] => ["Problematic", "A entrega não pode ser efetuada - Carteiro não atendido", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 22] => ["On the way", "Objeto devolvido aos Correios", "", "Acompanhar"],
    ["BDI", 22] => ["On the way", "Objeto devolvido aos Correios", "", "Acompanhar"],
    ["BDR", 22] => ["On the way", "Objeto devolvido aos Correios", "", "Acompanhar"],
    ["BDE", 23] => ["Returned", "Objeto devolvido ao remetente", "Recebido por:", "Acompanhar"],
    ["BDI", 23] => ["Returned", "Objeto devolvido ao remetente", "Recebido por:", "Acompanhar"],
    ["BDR", 23] => ["Returned", "Objeto devolvido ao remetente", "Recebido por:", "Acompanhar"],
    ["BDE", 24] => ["Waiting for pickup", "Objeto disponível para retirada em Caixa Postal", "", "Acompanhar"],
    ["BDI", 24] => ["Waiting for pickup", "Objeto disponível para retirada em Caixa Postal", "", "Acompanhar"],
    ["BDR", 24] => ["Waiting for pickup", "Objeto disponível para retirada em Caixa Postal", "", "Acompanhar"],
    ["BDE", 25] => ["Out for delivery", "A entrega não pode ser efetuada - Empresa sem expediente", "A entrega deverá ocorrer no próximo dia útil", "Acompanhar"],
    ["BDI", 25] => ["Out for delivery", "A entrega não pode ser efetuada - Empresa sem expediente", "A entrega deverá ocorrer no próximo dia útil", "Acompanhar"],
    ["BDR", 25] => ["Out for delivery", "A entrega não pode ser efetuada - Empresa sem expediente", "A entrega deverá ocorrer no próximo dia útil", "Acompanhar"],
    ["BDE", 26] => ["Waiting for pickup", "Destinatário não retirou objeto na Unidade dos Correios", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 26] => ["Waiting for pickup", "Destinatário não retirou objeto na Unidade dos Correios", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 26] => ["Waiting for pickup", "Destinatário não retirou objeto na Unidade dos Correios", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 28] => ["Problematic", "Objeto e/ou conteúdo avariado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 28] => ["Problematic", "Objeto e/ou conteúdo avariado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 28] => ["Problematic", "Objeto e/ou conteúdo avariado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDE", 30] => ["On the way", "Saída não efetuada", "Em tratamento, aguarde.", "Acompanhar"],
    ["BDI", 30] => ["On the way", "Saída não efetuada", "Em tratamento, aguarde.", "Acompanhar"],
    ["BDR", 30] => ["On the way", "Saída não efetuada", "Em tratamento, aguarde.", "Acompanhar"],
    ["BDE", 32] => ["On the way", "Objeto com data de entrega agendada", "", "Acompanhar"],
    ["BDI", 32] => ["On the way", "Objeto com data de entrega agendada", "", "Acompanhar"],
    ["BDR", 32] => ["On the way", "Objeto com data de entrega agendada", "", "Acompanhar"],
    ["BDE", 33] => ["Problematic", "A entrega não pode ser efetuada - Destinatário não apresentou documento exigido", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 33] => ["Problematic", "A entrega não pode ser efetuada - Destinatário não apresentou documento exigido", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 33] => ["Problematic", "A entrega não pode ser efetuada - Destinatário não apresentou documento exigido", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 34] => ["Problematic", "A entrega não pode ser efetuada - Logradouro com numeração irregular", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["BDI", 34] => ["Problematic", "A entrega não pode ser efetuada - Logradouro com numeração irregular", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["BDR", 34] => ["Problematic", "A entrega não pode ser efetuada - Logradouro com numeração irregular", "Objeto sujeito a atraso na entrega ou a devolução ao remetente", "Acompanhar"],
    ["BDE", 35] => ["Out for delivery", "Coleta ou entrega de objeto não efetuada", "Será realizada nova tentativa de coleta ou entrega", "Acompanhar"],
    ["BDI", 35] => ["Out for delivery", "Coleta ou entrega de objeto não efetuada", "Será realizada nova tentativa de coleta ou entrega", "Acompanhar"],
    ["BDR", 35] => ["Out for delivery", "Coleta ou entrega de objeto não efetuada", "Será realizada nova tentativa de coleta ou entrega", "Acompanhar"],
    ["BDE", 36] => ["Problematic", "Coleta ou entrega de objeto não efetuada", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 36] => ["Problematic", "Coleta ou entrega de objeto não efetuada", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 36] => ["Problematic", "Coleta ou entrega de objeto não efetuada", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 37] => ["Problematic", "Objeto e/ou conteúdo avariado por acidente com veículo", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 37] => ["Problematic", "Objeto e/ou conteúdo avariado por acidente com veículo", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 37] => ["Problematic", "Objeto e/ou conteúdo avariado por acidente com veículo", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDE", 38] => ["Problematic", "Objeto endereçado à empresa falida", "Objeto será encaminhado para entrega ao administrador judicial", "Acompanhar"],
    ["BDI", 38] => ["Problematic", "Objeto endereçado à empresa falida", "Objeto será encaminhado para entrega ao administrador judicial", "Acompanhar"],
    ["BDR", 38] => ["Problematic", "Objeto endereçado à empresa falida", "Objeto será encaminhado para entrega ao administrador judicial", "Acompanhar"],
    ["BDI", 39] => ["On the way", "A entrega não pode ser efetuada", "Objeto em análise de destinação", "Acompanhar"],
    ["BDR", 39] => ["On the way", "A entrega não pode ser efetuada", "Objeto em análise de destinação", "Acompanhar"],
    ["BDE", 40] => ["Problematic", "A importação do objeto/conteúdo não foi autorizada pelos órgãos fiscalizadores", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 40] => ["Problematic", "A importação do objeto/conteúdo não foi autorizada pelos órgãos fiscalizadores", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 40] => ["Problematic", "A importação do objeto/conteúdo não foi autorizada pelos órgãos fiscalizadores", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 41] => ["Problematic", "A entrega do objeto está condicionada à composição do lote", "", "Acompanhar"],
    ["BDI", 41] => ["Problematic", "A entrega do objeto está condicionada à composição do lote", "", "Acompanhar"],
    ["BDR", 41] => ["Problematic", "A entrega do objeto está condicionada à composição do lote", "", "Acompanhar"],
    ["BDE", 42] => ["Problematic", "Lote de objetos incompleto", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 42] => ["Problematic", "Lote de objetos incompleto", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 42] => ["Problematic", "Lote de objetos incompleto", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 43] => ["Problematic", "Objeto apreendido por órgão de fiscalização ou outro órgão anuente", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 43] => ["Problematic", "Objeto apreendido por órgão de fiscalização ou outro órgão anuente", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 43] => ["Problematic", "Objeto apreendido por órgão de fiscalização ou outro órgão anuente", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 75] => ["Problematic", "Objeto apreendido por => POLICIA FEDERAL", "O objeto está em poder da autoridade competente", "Acionar atendimento dos Correios."],
    ["BDE", 45] => ["On the way", "Objeto recebido na unidade de distribuição", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["BDI", 45] => ["On the way", "Objeto recebido na unidade de distribuição", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["BDR", 45] => ["On the way", "Objeto recebido na unidade de distribuição", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["BDE", 46] => ["On the way", "Tentativa de entrega não efetuada", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["BDI", 46] => ["On the way", "Tentativa de entrega não efetuada", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["BDR", 46] => ["On the way", "Tentativa de entrega não efetuada", "Entrega prevista para o próximo dia útil", "Acompanhar"],
    ["BDE", 47] => ["On the way", "Saída para entrega cancelada", "Será efetuado novo lançamento para entrega", "Acompanhar"],
    ["BDI", 47] => ["On the way", "Saída para entrega cancelada", "Será efetuado novo lançamento para entrega", "Acompanhar"],
    ["BDR", 47] => ["On the way", "Saída para entrega cancelada", "Será efetuado novo lançamento para entrega", "Acompanhar"],
    ["BDE", 48] => ["Problematic", "Retirada em Unidade dos Correios não autorizada pelo remetente", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 48] => ["Problematic", "Retirada em Unidade dos Correios não autorizada pelo remetente", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 48] => ["Problematic", "Retirada em Unidade dos Correios não autorizada pelo remetente", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 49] => ["Problematic", "As dimensões do objeto impossibilitam o tratamento e a entrega", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 49] => ["Problematic", "As dimensões do objeto impossibilitam o tratamento e a entrega", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 49] => ["Problematic", "As dimensões do objeto impossibilitam o tratamento e a entrega", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 50] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 50] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 50] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDE", 51] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 51] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 51] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDE", 52] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDI", 52] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDR", 52] => ["Lost", "Objeto roubado", "Favor entrar em contato com os Correios.", "Acionar atendimento dos Correios."],
    ["BDE", 53] => ["On the way", "Objeto reimpresso e reenviado", "", "Acompanhar. O objeto impresso pelos Correios precisou ser refeito e reenviado."],
    ["BDI", 53] => ["On the way", "Objeto reimpresso e reenviado", "", "Acompanhar. O objeto impresso pelos Correios precisou ser refeito e reenviado."],
    ["BDR", 53] => ["On the way", "Objeto reimpresso e reenviado", "", "Acompanhar. O objeto impresso pelos Correios precisou ser refeito e reenviado."],
    ["BDE", 54] => ["Problematic", "Para recebimento do objeto, é necessário o pagamento do ICMS Importação", "", "Acompanhar. O interessado deverá pagar o imposto devido para retirar o objeto em uma Unidade dos Correios."],
    ["BDI", 54] => ["Problematic", "Para recebimento do objeto, é necessário o pagamento do ICMS Importação", "", "Acompanhar. O interessado deverá pagar o imposto devido para retirar o objeto em uma Unidade dos Correios."],
    ["BDR", 54] => ["Problematic", "Para recebimento do objeto, é necessário o pagamento do ICMS Importação", "", "Acompanhar. O interessado deverá pagar o imposto devido para retirar o objeto em uma Unidade dos Correios."],
    ["BDE", 55] => ["Problematic", "Solicitada revisão do tributo estabelecido", "", "Acompanhar"],
    ["BDI", 55] => ["Problematic", "Solicitada revisão do tributo estabelecido", "", "Acompanhar"],
    ["BDR", 55] => ["Problematic", "Solicitada revisão do tributo estabelecido", "", "Acompanhar"],
    ["BDE", 56] => ["Problematic", "Declaração aduaneira ausente ou incorreta", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDI", 56] => ["Problematic", "Declaração aduaneira ausente ou incorreta", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDR", 56] => ["Problematic", "Declaração aduaneira ausente ou incorreta", "Objeto será devolvido ao remetente", "Acompanhar o retorno do objeto ao remetente."],
    ["BDE", 57] => ["On the way", "Revisão de tributo concluída - Objeto liberado", "", "Acompanhar"],
    ["BDI", 57] => ["On the way", "Revisão de tributo concluída - Objeto liberado", "", "Acompanhar"],
    ["BDR", 57] => ["On the way", "Revisão de tributo concluída - Objeto liberado", "", "Acompanhar"],
    ["BDE", 58] => ["On the way", "Revisão de tributo concluída - Tributo alterado", "O valor do tributo pode ter aumentado ou diminuído", "Acompanhar"],
    ["BDI", 58] => ["On the way", "Revisão de tributo concluída - Tributo alterado", "O valor do tributo pode ter aumentado ou diminuído", "Acompanhar"],
    ["BDR", 58] => ["On the way", "Revisão de tributo concluída - Tributo alterado", "O valor do tributo pode ter aumentado ou diminuído", "Acompanhar"],
    ["BDE", 59] => ["On the way", "Revisão de tributo concluída - Tributo mantido", "Poderá haver incidência de juros e multa.", "Acompanhar"],
    ["BDI", 59] => ["On the way", "Revisão de tributo concluída - Tributo mantido", "Poderá haver incidência de juros e multa.", "Acompanhar"],
    ["BDR", 59] => ["On the way", "Revisão de tributo concluída - Tributo mantido", "Poderá haver incidência de juros e multa.", "Acompanhar"],
    ["BDR", 60] => ["On the way", "O objeto encontra-se aguardando prazo para refugo", "", "Acompanhar"],
    ["BDI", 60] => ["On the way", "O objeto encontra-se aguardando prazo para refugo", "", "Acompanhar"],
    ["BDE", 66] => ["On the way", "Área com distribuição sujeita a prazo diferenciado", "Restrição de entrega domiciliar temporária", "Acompanhar"],
    ["BDI", 66] => ["On the way", "Área com distribuição sujeita a prazo diferenciado", "Restrição de entrega domiciliar temporária", "Acompanhar"],
    ["BDR", 66] => ["On the way", "Área com distribuição sujeita a prazo diferenciado", "Restrição de entrega domiciliar temporária", "Acompanhar"],
    ["BDE", 68] => ["Waiting for pickup", "Objeto aguardando retirada em armário inteligente", "Estará disponível por até 3 dias, a partir de hoje", "Acompanhar"],
    ["BDI", 68] => ["Waiting for pickup", "Objeto aguardando retirada em armário inteligente", "Estará disponível por até 3 dias, a partir de hoje", "Acompanhar"],
    ["BDR", 68] => ["Waiting for pickup", "Objeto aguardando retirada em armário inteligente", "Estará disponível por até 3 dias, a partir de hoje", "Acompanhar"],
    ["BDE", 69] => ["On the way", "Objeto com atraso na entrega", "", "Acompanhar"],
    ["BDI", 69] => ["On the way", "Objeto com atraso na entrega", "", "Acompanhar"],
    ["BDR", 69] => ["On the way", "Objeto com atraso na entrega", "", "Acompanhar"],
    ["BDE", 80] => ["Lost", "Objeto extraviado", "", "Acionar a CAC dos Correios"],
    ["BDI", 80] => ["Lost", "Objeto extraviado", "", "Acionar a CAC dos Correios"],
    ["BDR", 80] => ["Lost", "Objeto extraviado", "", "Acionar a CAC dos Correios"],
    ["CMR", 1] => ["On the way", "Conferido", "", "Acompanhar"]
  }

  NUMERO_DIRETORIA = {
    ['ACRE','AC'] => '03',
    ['ALAGOAS','AL'] => '04',
    ['AMAPÁ','AP'] => '05',
    ['AMAZONAS','AM'] => '06',
    ['BAHIA','BA'] => '08',
    ['BRASÍLIA','DF'] => '10',
    ['CEARÁ','CE'] => '12',
    ['ESPIRITO SANTO','ES'] => '14',
    ['GOIÁS','GO'] => '16',
    ['MARANHÃO','MA'] => '18',
    ['MINAS GERAIS','MG'] => '20',
    ['MATO GROSSO DO SUL','MS'] => '22',
    ['MATO GROSSO','MT'] => '24',
    ['PARÁ','PA'] => '28',
    ['PARAÍBA','PB'] => '30',
    ['PERNAMBUCO','PE'] => '32',
    ['PIAUÍ','PI'] => '34',
    ['PARANÁ','PR'] => '36',
    ['RIO DE JANEIRO','RJ'] => '50',
    ['RIO GRANDE DO NORTE','RN'] => '60',
    ['RIO GRANDE DO SUL', 'RS'] => '64',
    ['RONDONIA','RO'] => '26',
    ['RORAIMA', 'RR'] => '65',
    ['SANTA CATARINA', 'SC'] => '68',
    ['SERGIPE', 'SE'] => '70',
    ['TOCANTINS','TO'] => '75',
    ['SÃO PAULO', 'SP'] => '72',
    ['SÃO PAULO INTERIOR', 'SPI'] => '74'
  }

  # REQUIRED METHODS
  # Use carrier.rb as a guideline to know which methods should be overwritten here.

  def self.settings
    [
      { field: 'sigep_user', type:'text' },
      { field: 'sigep_password', type:'password' },
      { field: 'tracking_user', type:'text' },
      { field: 'tracking_password', type:'password' },
      { field: 'administrative_code', type:'text' },
      { field: 'contract', type:'text' },
      { field: 'posting_card', type:'text' },
      { field: 'cnpj', type:'text' },
      { field: 'pac_label_minimum_quantity', type:'text' },
      { field: 'pac_label_reorder_quantity', type:'text' },
      { field: 'pac_service_id', type:'text' },
      { field: 'pac_posting_code', type:'text' },
      { field: 'sedex_label_minimum_quantity', type:'text' },
      { field: 'sedex_label_reorder_quantity', type:'text'},
      { field: 'sedex_service_id', type: 'text' },
      { field: 'sedex_posting_code', type: 'text' },
      { field: 'label_type', type: 'dropdown', options:["simple_label", "tracked_label"]}
    ]
  end

  def authenticate!
    services = available_services
    message = "Estes são os serviços disponíveis para sua conta: <br>"
    services.each do |service|
      message << "<br>#{service[:description].strip}"
      message << "<br>ID do Serviço: #{service[:service_id].strip}, Código de Postagem: #{service[:posting_code].strip}<br>"
    end
    message
  end

  def get_delivery_updates(shipment)
    message = {
      "usuario" => carrier_setting.settings["tracking_user"],
      "senha" => carrier_setting.settings["tracking_password"],
      "tipo" => "L",
      "resultado" => "T",
      "lingua" => "101",
      "objetos" => shipment.tracking_number
    }
    response = tracking_connection.call(:busca_eventos, message: message)
    events = response.body.dig(:busca_eventos_response, :return, :objeto,:evento)
    error = response.body.dig(:busca_eventos_response, :return, :objeto, :erro)
    raise Exception.new("Correios: #{error}") if error
    delivery_updates = []
    events.each do |event|
      key = [event[:tipo], event[:status].to_i]
      delivery_updates << {
        date: "#{event[:data]} #{event[:hora]}",
        description: "#{event[:descricao]} em #{event[:cidade]}, #{event[:uf]}. #{event[:local]}",
        status_code: "#{event[:tipo]} - #{event[:status]}",
        bearpost_status: STATUS_CODES[key].try(:[], 0)
      }
    end
    delivery_updates
  end

  def get_tracking_number(shipment)
    shipping_method = shipment.shipping_method
    check_tracking_number_availability(shipping_method)
    shipping_method_settings = carrier_setting.settings[shipping_method]
    current_range = shipping_method_settings['ranges'].first
    prefix        = current_range['prefix']
    number        = current_range['next_number']
    sufix         = current_range['sufix']
    verification_digit = get_verification_digit(number)
    tracking_number    = "#{prefix}#{number.to_s.rjust(8,"0")}#{verification_digit}#{sufix}"
    if current_range['next_number'] + 1 > current_range['last_number']
      carrier_setting.settings[shipping_method]['ranges'].delete(current_range)
    else
      current_range['next_number'] += 1
    end
    carrier_setting.save
    tracking_number
  end

  def transmit_shipments(shipments)
    response = []
    grouped_shipments = group_shipments_by_shipping_method(shipments)
    grouped_shipments.each do |shipping_method, shipments|
      correios_response = create_plp(shipments)
      plp_number = correios_response.body.dig(:fecha_plp_varios_servicos_response,:return)
      message = "Enviado na PLP #{plp_number}"
      shipments.each do |shipment|
        settings = shipment.settings
        settings['plp'] = plp_number
        shipment.update(settings:settings, transmitted_to_carrier:true)
        response << {
          shipment: shipment,
          success: shipment.transmitted_to_carrier,
          message: message
        }
      end
    end
    response
  end

  # OPTIONAL METHODS
  # Use carrier.rb as a guideline to know which methods can be overwritten here.

  def self.custom_label_view
    'correios_label'
  end

  def before_get_label(shipment)
    if carrier_setting.settings['label_type'] == 'tracked_label' && shipment.tracking_number.blank?
      shipment.tracking_number = get_tracking_number(shipment)
      shipment.save
    end
  end

  # CARRIER SPECIFIC METHODS
  # Internal carrier methods that are used by the required methods above.

  def group_shipments_by_shipping_method(shipments)
    grouped_shipments = {}
    shipments.each do |shipment|
      grouped_shipments[shipment.shipping_method] ||= []
      grouped_shipments[shipment.shipping_method] << shipment
    end
    grouped_shipments
  end

  def get_ranges_from_correios(shipping_method)
    reorder_quantity = carrier_setting.settings["#{shipping_method.downcase}_label_reorder_quantity"] || "10"
    message = {
      "tipoDestinatario" =>  "C",
      "identificador" => carrier_setting.settings["cnpj"],
      "idServico" => carrier_setting.settings["#{shipping_method.downcase}_service_id"],
      "qtdEtiquetas" => reorder_quantity,
      "usuario" => carrier_setting.settings["sigep_user"],
      "senha" => carrier_setting.settings["sigep_password"],
    }
    response = connection.call(:solicita_etiquetas, message: message)
    ranges   = response.body.dig(:solicita_etiquetas_response, :return)
    ranges.split(',')
  end

  def save_new_range(shipping_method)
    ranges_array = get_ranges_from_correios(shipping_method)
    next_number  = ranges_array[0].numbers_only
    last_number  = ranges_array[1].numbers_only
    prefix       = ranges_array[0][0..1]
    sufix        = ranges_array[0][-2..-1]
    range_hash   = {
      "created_at":  DateTime.now,
      "prefix":      prefix,
      "next_number": next_number.to_i,
      "last_number": last_number.to_i,
      "sufix":       sufix,
    }
    carrier_setting.settings[shipping_method] ||= {}
    carrier_setting.settings[shipping_method]['ranges'] ||= []
    carrier_setting.settings[shipping_method]['ranges'] << range_hash
    carrier_setting.save
  end

  def count_available_labels(shipping_method)
    ranges = carrier_setting.settings.dig(shipping_method,'ranges')
    return 0 unless ranges.present?
    total = 0
    ranges.each do |range|
      total += range['last_number'] - range['next_number'] + 1
    end
    total
  end

  def check_tracking_number_availability(shipping_method)
    minimum_quantity = carrier_setting.settings["#{shipping_method.downcase}_label_minimum_quantity"].to_i
    if count_available_labels(shipping_method) < minimum_quantity
      save_new_range(shipping_method)
    end
  end

  def check_posting_card(account)
    message = {
      "usuario" => carrier_setting.settings["sigep_user"],
      "senha" => carrier_setting.settings["sigep_password"],
      "numeroCartaoPostagem" => carrier_setting.settings["posting_card"],
    }
    response = connection.call(:get_status_cartao_postagem, message: message)

    response.body.dig(:get_status_cartao_postagem_response,:return)
  end

  def create_plp(shipments)
    shipments_without_tracking = shipments.select {|shipment| shipment.tracking_number.blank?}
    raise Exception.new("Envios #{shipments_without_tracking.pluck(:shipment_number)} não possuem rastreio") if shipments_without_tracking.any?
    user     = carrier_setting.settings["sigep_user"]
    password = carrier_setting.settings["sigep_password"]
    posting_card = carrier_setting.settings["posting_card"]
    xml = build_xml(shipments)
    labels = []
    shipments.each do |shipment|
      labels << shipment.tracking_number[0..9] + shipment.tracking_number[-2..-1]
    end
    message = {
      :xml =>  xml,
      :id_plp_cliente => 123123,
      :cartao_postagem => posting_card,
      :lista_etiquetas => labels,
      :usuario => user,
      :senha => password,
    }
    connection.call(:fecha_plp_varios_servicos, message: message)
  end

  def get_plp_xml(plp_number)
    message = {
      "idPlpMaster" => plp_number,
      "usuario" => carrier_setting.settings["sigep_user"],
      "senha" => carrier_setting.settings["sigep_password"],
    }
    connection.call(:solicita_xml_plp, message:message)
  end

  def build_xml(shipments)
    account  = shipments.first.account
    posting_code = carrier_setting.settings["#{shipments.first.shipping_method.downcase}_posting_code"]
    posting_card = carrier_setting.settings["posting_card"]
    contract = carrier_setting.settings["contract"]
    administrative_code = carrier_setting.settings["administrative_code"]


    builder = Nokogiri::XML::Builder.new(:encoding => 'ISO-8859-1') do |xml|
      xml.correioslog {
        xml.tipo_arquivo 'Postagem'
        xml.versao_arquivo '2.3'
        xml.plp {
          xml.id_plp
          xml.valor_global
          xml.mcu_unidade_postagem
          xml.nome_unidade_postagem
          xml.cartao_postagem posting_card.rjust(10,'0')
        }
        xml.remetente {
          xml.numero_contrato contract.slice(0,10)
          xml.numero_diretoria get_numero_diretoria(account.state)
          xml.codigo_administrativo administrative_code.slice(0,8)
          xml.nome_remetente { xml.cdata account.name.slice(0,50) }
          xml.logradouro_remetente { xml.cdata account.street.slice(0,50) }
          xml.numero_remetente { xml.cdata account.number.slice(0,5) }
          xml.complemento_remetente { xml.cdata account.complement.slice(0,30) }
          xml.bairro_remetente { xml.cdata account.neighborhood.slice(0,30) }
          xml.cep_remetente { xml.cdata account.zip.numbers_only.slice(0,8) }
          xml.cidade_remetente { xml.cdata account.city.slice(0,30) }
          xml.uf_remetente account.state.slice(0,2)
          xml.telefone_remetente { xml.cdata account.phone.numbers_only.slice(0,12) }
          xml.email_remetente { xml.cdata account.email.slice(0,50) }
          xml.cpf_cnpj_remetente account.cnpj.numbers_only.slice(0,14)
          xml.ciencia_conteudo_proibido 'S'
        }
        xml.forma_pagamento
        shipments.each do |shipment|
          invoice = shipment.invoice_xml ? Nokogiri::XML(shipment.invoice_xml) : nil
          invoice_value = invoice ? invoice.at_css('vNF').content.sub(".",",") : nil
          package = shipment.packages.last
          xml.objeto_postal {
            xml.numero_etiqueta shipment.tracking_number.slice(0,13)
            xml.codigo_objeto_cliente
            xml.codigo_servico_postagem posting_code.slice(0,5)
            xml.cubagem '0,00'
            xml.peso (package.weight * 1000).round.to_s.slice(0,5)
            xml.rt2
            xml.destinatario {
              xml.nome_destinatario { xml.cdata shipment.full_name.slice(0,50) }
              xml.celular_destinatario { xml.cdata shipment.phone.numbers_only.slice(0,12) }
              xml.email_destinatario { xml.cdata shipment.email.slice(0,50) }
              xml.logradouro_destinatario { xml.cdata shipment.street.slice(0,50) }
              xml.complemento_destinatario { xml.cdata shipment.complement.slice(0,30) }
              xml.numero_end_destinatario { xml.cdata shipment.number.slice(0,5) }
            }
            xml.nacional {
              xml.bairro_destinatario { xml.cdata shipment.neighborhood.slice(0,30) }
              xml.cidade_destinatario { xml.cdata shipment.city.slice(0,30) }
              xml.uf_destinatario shipment.state.slice(0,2)
              xml.cep_destinatario { xml.cdata shipment.zip.numbers_only.slice(0,8) }
              xml.numero_nota_fiscal shipment.invoice_number.to_s.slice(0,7)
              xml.serie_nota_fiscal shipment.invoice_series.to_s.slice(0,20)
              xml.natureza_nota_fiscal
              xml.valor_nota_fiscal invoice_value
            }
            xml.servico_adicional {
              xml.codigo_servico_adicional '025'
              if invoice
                xml.codigo_servico_adicional '064' if shipment.shipping_method == "PAC"
                xml.codigo_servico_adicional '019' if shipment.shipping_method == "SEDEX"
                xml.valor_declarado invoice_value
              end
            }
            xml.dimensao_objeto {
              xml.tipo_objeto '002' # Pacote / Caixa
              xml.dimensao_altura package.heigth.to_s.sub(".",",").slice(0,9)
              xml.dimensao_largura package.width.to_s.sub(".",",").slice(0,9)
              xml.dimensao_comprimento package.depth.to_s.sub(".",",").slice(0,9)
              xml.dimensao_diametro 0
            }
          }
        end
      }
    end
    builder.to_xml.encode('UTF-8')
  end

  def get_numero_diretoria(state)
    NUMERO_DIRETORIA.find {|key,value| key.include?(state.upcase)}[1]
  end

  # Method for getting available services and their IDs - Use it to find your pac_service_id and sedex_service_id
  def available_services
    settings = carrier_setting.settings
    user = settings['sigep_user']
    password = settings['sigep_password']
    posting_card = settings['posting_card']
    contract = settings['contract']

    message = {
      "idContrato" => contract,
      "idCartaoPostagem" => "00#{posting_card}",
      "usuario" => user,
      "senha" => password,
    }

    connection = Savon.client(wsdl: LIVE_URL, headers: { 'SOAPAction' => '' })
    response = connection.call(:busca_cliente, message:message)
    response.body.dig(:busca_cliente_response, :return, :contratos, :cartoes_postagem, :servicos).map { |servico| { description: servico[:descricao], service_id: servico[:id], posting_code: servico[:codigo]  } }
  end

  def connection
    url = test_mode? ? TEST_URL : LIVE_URL
    Savon.client(
      wsdl: url,
      headers: { 'SOAPAction' => '' },
      pretty_print_xml: true,
      log: Rails.env.development?,
    )
  end

  def tracking_connection
    Savon.client(
      wsdl: "http://webservice.correios.com.br/service/rastro/Rastro.wsdl",
      headers: { 'SOAPAction' => '' }
    )
  end

  def get_verification_digit(number)
    multipliers = [8, 6, 4, 2, 3, 5, 9, 7]
    total = 0

    number.to_s.rjust(8,"0").chars.map(&:to_i).each_with_index do |number,index|
      total += number * multipliers[index]
    end
    remainder = total % 11
    if remainder == 0
      verification_digit = 5;
    elsif remainder == 1
      verification_digit = 0;
    else
      verification_digit = 11 - remainder
    end
    verification_digit
  end

  def data_matrix(shipment)
    account = shipment.account
    str = ""
    str += shipment.zip
    if shipment.number.numbers_only == shipment.number
      str += shipment.number.rjust(4, "0")
    else
      str += "0000"
    end
    str += account.zip
    if account.number.numbers_only == account.number
      str += account.number.rjust(4, "0")
    else
      str += "0000"
    end
    zip_sum = shipment.zip.split('').reduce(0){|sum, num| sum + num.to_i}
    if zip_sum % 10 == 0
      str += "0"
    else
      str += (10 - zip_sum % 10).to_s
    end
    str += "51"
    str += shipment.tracking_number
    str += "250000000000"
    str += carrier_setting.settings['posting_card']
    str += carrier_setting.settings["#{shipment.shipping_method.downcase}_service_id"]
    str += "00"
    str += shipment.number.rjust(5, "0")
    str += shipment.complement.rjust(20, " ")
    str += shipment.complement.rjust(20, " ")
    str += "00000" # Declared amount
    str += shipment.phone.numbers_only.rjust(12, "0")
    str += "-00.000000"
    str += "-00.000000"
    str += "|"
  end
end
