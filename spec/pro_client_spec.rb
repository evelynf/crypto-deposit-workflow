require './app/pro_client'

describe ProClient do

    describe '#order' do
        before do
            allow_any_instance_of(Coinbase::Exchange::Client).to receive(:order)
        end
        let(:size) { 1 }
        let(:product_id) { 'BTC-USD'}
        let(:side) { :sell }
        let(:type) { :market }

        it 'calls order successfully' do
            expect_any_instance_of(Coinbase::Exchange::Client).to receive(:order).with(
                { 
                    size: 1,
                    product_id: product_id,
                    side: side,
                    type: type
                }
            )
            described_class.new.order(type, side, product_id, size: size)
        end

        context 'when size or funds is not passed in' do
            let(:execute) {  described_class.new.order(type, side, product_id) }

            it 'raises an argument error' do
                expect { execute }.to raise_error(ArgumentError)
            end
        end
    end
end