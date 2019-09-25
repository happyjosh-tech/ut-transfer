import { connect } from 'react-redux';
import Pagination from 'ut-front-react/components/AdvancedPagination';
import { updatePagination } from './actions';

export default connect((state) => ({
    pagination: state.transferPartnersPagination.get('pagination'),
    cssStandard: true
}), { onUpdate: updatePagination })(Pagination);
