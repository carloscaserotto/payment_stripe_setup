class CreateProducts < ActiveRecord::Migration[6.1]
  def change
    create_table :products do |t|
      t.string :name
      t.string :stripe_plan_name
      t.string :paypal_plan_name

      t.timestamps
    end
    add_money :products, :price, currency: { present: true}
  end
end
