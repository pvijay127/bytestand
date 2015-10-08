class AmazonAccountsController < AuthenticatedController
  skip_before_action :amazon_account_set?
  after_action :get_merchant_products_list, only: [:create, :update]

  def new

  end

  def create
    if amazon_account.save
      redirect_to session[:previous_path]
      session.delete(:previous_path)
    else
      flash.alert = "The following errors prevent account saving, please correct them and try again."
      render :new
    end
  end

  def edit

  end

  def update
    if amazon_account.save
      redirect_to edit_amazon_account_path, notice: 'Updated successfully.'
    else
      flash.alert =  "The following errors prevent account saving, please correct them and try again."
      render :edit
    end
  end


  helper_method :amazon_account
  private
  def amazon_account
    return @amazon_account if @amazon_account
    @amazon_account = AmazonAccount.find_or_initialize_by(shop: current_shop)
    @amazon_account.attributes = amazon_account_params if params.has_key?(:amazon_account)
    @amazon_account
  end

  def amazon_account_params
    params.require(:amazon_account).permit(:merchant_id, :marketplace_id, :auth_token)
  end

  def get_merchant_products_list
    if amazon_account.valid?
      GetAmazonProductsJob.perform_later(amazon_account_params)
    end
  end
end
