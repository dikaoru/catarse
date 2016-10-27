class AddMercadoPagoRefreshToken < ActiveRecord::Migration
  def self.up
    add_column :projects, :mercado_pago_refresh_token, :string, :limit => 100
  end

  def self.down
    remove_column :projects, :mercado_pago_refresh_token
  end
end
